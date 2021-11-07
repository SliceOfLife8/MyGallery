//
//  EditCustomAlbumVC.swift
//  MyGallery
//
//  Created by Christos Petimezas on 29/6/21.
//

import UIKit
import Photos
import Loaf

class EditCustomAlbumVC: BaseVC {
    
    // MARK: - Vars
    private(set) var viewModel: EditAlbumViewModel
    private(set) var service: PhotoService
    
    // MARK: - Vars about collectionView
    internal weak var collectionView: UICollectionView?
    internal lazy var numberOfElementsInRow: CGFloat = 3
    internal var minimumItemSpacingAtSameRow: CGFloat = 8
    internal var minimumItemSpacingBetweenGrids: CGFloat = 8
    internal lazy var cellIdentifier = "GalleryCell"
    
    let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    fileprivate(set) lazy var thumbnailImageSize: CGSize = {
        return self.estimateSizeOfImages()
    }()
    var selectedIndexPaths: [IndexPath] = [] /// Track selected indexPaths. We need reference to selected cells as we don't have index of them when reuse automatically occrus.
    
    // MARK: - Outlets
    @IBOutlet weak var noAssetsView: GradientView!
    @IBOutlet weak var noAssetsLbl: UILabel!
    
    // MARK: - Init
    init(_ viewModel: EditAlbumViewModel = EditAlbumViewModel()) {
        self.viewModel = viewModel
        self.service = PhotoService.shared
        super.init(nibName: nil, bundle: nil)
        configure(viewModel: viewModel)
    }
    
    func configure(viewModel: EditAlbumViewModel) {
        viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        populateData()
        setupNoAssetsView()
        defaultStateView()

        // Observe photo library changes
        PHPhotoLibrary.shared().register(self)
    }
    
    private func setupNavigationBar() {
        self.navigationItem.title = "edit_album".localized()
        self.navigationController?.navigationBar.tintColor = UIColor(named: "Black")
        self.navigationItem.largeTitleDisplayMode = .never
        updateBarRightItem()
    }
    
    private func populateData() {
        service.fetchAssets()
        service.fetchCustomAlbumPhotos()
    }
    
    func updateBarRightItem() {
        if selectedIndexPaths.isEmpty {
            // Create pull-down menu
            let bar = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style: .plain, target: self, action: nil)
            self.navigationItem.rightBarButtonItem = bar
            self.navigationItem.rightBarButtonItem?.menu = addMenuItemsToDotsView()

        } else {
            let bar = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: nil)
            self.navigationItem.rightBarButtonItem = bar
            self.navigationItem.rightBarButtonItem?.menu = addMenuItemsToTrashView()
        }
    }
    
    private func setupNoAssetsView() {
        if self.traitCollection.userInterfaceStyle == .dark {
            noAssetsView.topGradientColor = UIColor(hexString: "#000000") //Labor Worker
            noAssetsView.bottomGradientColor = UIColor(hexString: "#2c3e50")
        } else {
            noAssetsView.topGradientColor = UIColor(hexString: "#d7e1ec") // Sweet Airan
            noAssetsView.bottomGradientColor = UIColor(hexString: "#ffffff")
        }
        noAssetsLbl.text = "no_album_found".localized()
        noAssetsLbl.textColor = UIColor(named: "Black")
    }

    private func restoreView() {
        updateBarRightItem()
        if let title = viewModel.loafTitle?.raw {
            Loaf(title, state: .custom(.init(backgroundColor: UIColor(hexString: "#2ecc71"), icon: Loaf.Icon.success, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
        }
        self.playMusicIfEnabled(.message)
        defaultStateView()
        viewModel.loafTitle = nil
    }

    private func defaultStateView() {
        collectionView?.isHidden = (service.photoAssets.count == 0) ? true : false
        noAssetsView.isHidden = (service.photoAssets.count == 0) ? false : true
    }
    
}

// MARK: - EditAlbumViewModel Delegate
extension EditCustomAlbumVC: EditAlbumVMDelegate {

    func cleanData() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.deleteCoreData()
        }
    }
    
    func didDeleteAlbum(status: Bool) {
        DispatchQueue.main.async {
            if status {
                guard let title = self.viewModel.loafTitle?.raw else { return }
                Loaf(title, state: .custom(.init(backgroundColor: UIColor(hexString: "#2ecc71"), icon: Loaf.Icon.success, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
                self.playMusicIfEnabled(.message)
                self.collectionView?.isHidden = true
                self.noAssetsView.isHidden = false
            } else {
                Loaf("something_went_wrong".localized(), state: .custom(.init(backgroundColor: UIColor(named: "Red")!, icon: Loaf.Icon.error, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
                self.playMusicIfEnabled(.error)
            }
        }
    }
    
}

// MARK: - PHPhotoLibraryChangeObserver delegate
extension EditCustomAlbumVC: PHPhotoLibraryChangeObserver {
    /**
     # "removedIndexes" and "insertedIndexes" go first because this indexes are relative to the original fetch result

     # "removedIndexes" - "indexes are relative to the original fetch result (the fetchResultBeforeChanges property); when updating your app’s interface, apply removals before insertions, changes, and moves." "insertedIndexes" - "indexes are relative to the original fetch result (the fetchResultBeforeChanges property) after you’ve applied the changes described by the removedIndexes property; when updating your app’s interface, apply insertions after removals and before changes and moves."

     # "changedIndexes" can't be processed with "delete"/"insert" because they describe items after insertions/deletions

     # "changedIndexes" - "These indexes are relative to the original fetch result (the fetchResultBeforeChanges property) after you’ve applied the changes described by the removedIndexes and insertedIndexes properties; when updating your app’s interface, apply changes after removals and insertions and before moves.

     # Warning Don't map changedIndexes directly to UICollectionView item indices in batch updates. Use these indices to reconfigure the corresponding cells after performBatchUpdates(_:completion:). UICollectionView and UITableView expect the changedIndexes to be in the before state, while PhotoKit provides them in the after state, resulting in a crash if your app performs insertions and deletions at the same time as the changes."

     # "enumerateMoves" is the last thing we should do.

     # "enumerateMoves" - "The toIndex parameter in the handler block is relative to the state of the fetch result after you’ve applied the changes described by the removedIndexes, insertedIndexes and changedIndexes properties. Therefore, if you use this method to update a collection view or similar user interface displaying the contents of the fetch result, update your UI to reflect insertions, removals, and changes before you process moves."
     */
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let collectionView = self.collectionView, let assetCollection = service.assetCollection else { return }
        // Change notifications may be made on a background queue.
        // Re-dispatch to the main queue to update the UI.
        DispatchQueue.main.sync {
            // Check for changes to the displayed album itself
            // (its existence and metadata, not its member assets).
            if let albumChanges = changeInstance.changeDetails(for: assetCollection) {
                // If album delete return
                if albumChanges.objectWasDeleted == true { return }
                // Fetch the new album and update the UI accordingly.
                service.assetCollection = albumChanges.objectAfterChanges!
            }
            // Check for changes to the list of assets (insertions, deletions, moves, or updates).
            if let changes = changeInstance.changeDetails(for: service.photoAssets) {
                // Keep the new fetch result for future use.
                service.photoAssets = changes.fetchResultAfterChanges
                if changes.hasIncrementalChanges {
                    // If there are incremental diffs, animate them in the collection view.
                    collectionView.performBatchUpdates({
                        // For indexes to make sense, updates must be in this order:
                        // delete, insert, reload, move
                        if let removed = changes.removedIndexes, removed.count > 0 {
                            self.removeIndexPaths(removed)
                            collectionView.deleteItems(at: removed.map { IndexPath(item: $0, section:0) })
                        }
                        if let inserted = changes.insertedIndexes, inserted.count > 0 {
                            collectionView.insertItems(at: inserted.map { IndexPath(item: $0, section:0) })
                        }
                    }) { _ in
                        //                        if let changed = changes.changedIndexes, changed.count > 0 {
                        //                            collectionView.reloadItems(at: changed.map { IndexPath(item: $0, section:0) })
                        //                        }
                        collectionView.performBatchUpdates({
                            // enumerateMoves
                            changes.enumerateMoves { fromIndex, toIndex in
                                collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                        to: IndexPath(item: toIndex, section: 0))
                            }
                        })
                    }
                    /// Also, fetch new images for lightBox controller
                    service.fetchCustomAlbumPhotos()
                } else {
                    // Reload the collection view if incremental diffs are not available.
                    self.selectedIndexPaths.removeAll()
                    collectionView.reloadData()
                }
                restoreView()
            }
        }
    }

    private func removeIndexPaths(_ set: IndexSet) {
        let removed = set.map { IndexPath(item: $0, section:0) }
        removed.forEach { indexPath in
            selectedIndexPaths = selectedIndexPaths.filter { $0 != indexPath }
        }
    }
}
