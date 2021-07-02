//
//  EditCustomAlbumVC.swift
//  MyGallery
//
//  Created by Christos Petimezas on 29/6/21.
//

import UIKit
import Photos
import DropDown
import Loaf

class EditCustomAlbumVC: BaseVC {
    
    // MARK: - Vars
    private(set) var viewModel: EditAlbumViewModel
    
    // MARK: - Vars about collectionView
    internal weak var collectionView: UICollectionView?
    var collectionViewFlowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    internal lazy var numberOfElementsInRow = 3
    internal var minimumItemSpacingAtSameRow: CGFloat = 8
    internal var minimumItemSpacingBetweenGrids: CGFloat = 8
    internal lazy var cellIdentifier = "GalleryCell"
    
    let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    fileprivate(set) lazy var thumbnailImageSize: CGSize = {
        return self.estimateSizeOfImages()
    }()
    var selectedIndexPaths: [IndexPath] = [] /// Track selected indexPaths. We need reference to selected cells as we don't have index of them when reuse automatically occrus.
    let dropDownForDotsView = DropDown()
    let dropDownForTrashView = DropDown()
    
    // MARK: - Outlets
    @IBOutlet weak var noAssetsView: GradientView!
    @IBOutlet weak var noAssetsLbl: UILabel!
    
    // MARK: - Init
    init(_ viewModel: EditAlbumViewModel) {
        self.viewModel = viewModel
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
        
        Loaf("select_images".localized(), state: .custom(.init(backgroundColor: UIColor(named: "DarkGray")!, icon: nil, textAlignment: .center)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
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
        viewModel.fetchCustomAlbumPhotos()
    }
    
    func updateBarRightItem() {
        if selectedIndexPaths.isEmpty {
            // Create pull-down menu
            if #available(iOS 14.0, *) {
                let bar = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style: .plain, target: self, action: nil)
                self.navigationItem.rightBarButtonItem = bar
                self.navigationItem.rightBarButtonItem?.menu = addMenuItemsToDotsView()
            } else {
                let bar = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(barLinesTapped))
                self.navigationItem.rightBarButtonItem = bar
                addDropDownMenuForDotsView()
            }
        } else {
            if #available(iOS 14.0, *) {
                let bar = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: nil)
                self.navigationItem.rightBarButtonItem = bar
                self.navigationItem.rightBarButtonItem?.menu = addMenuItemsToTrashView()
            } else {
                let bar = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(trashTapped))
                self.navigationItem.rightBarButtonItem = bar
                addDropDownMenuForTrashView()
            }
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
    
    // MARK: - Actions
    @objc func barLinesTapped() {
        dropDownForDotsMenuTapped()
    }
    
    @objc func trashTapped() {
        dropDownForTrashMenuTapped()
    }
    
}

// MARK: - EditAlbumViewModel Delegate
extension EditCustomAlbumVC: EditAlbumVMDelegate {
    
    func didGetImages() {
        if viewModel.images.count == 0 {
            self.collectionView?.isHidden = true
            self.noAssetsView.isHidden = false
        } else {
            self.collectionView?.reloadData()
        }
    }
    
    func didDeleteAlbum(status: Bool) {
        DispatchQueue.main.async {
            if status {
                Loaf(self.viewModel.loafTitle.raw, state: .custom(.init(backgroundColor: UIColor(hexString: "#2ecc71"), icon: Loaf.Icon.success, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
                self.collectionView?.isHidden = true
                self.noAssetsView.isHidden = false
            } else {
                Loaf("something_went_wrong".localized(), state: .custom(.init(backgroundColor: UIColor(named: "RedColor")!, icon: Loaf.Icon.error, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
            }
        }
    }
    
}

// MARK: - PHPhotoLibraryChangeObserver delegate
extension EditCustomAlbumVC: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let collectionView = self.collectionView, let assetCollection = viewModel.assetCollection else { return }
        // Change notifications may be made on a background queue.
        // Re-dispatch to the main queue to update the UI.
        DispatchQueue.main.sync {
            // Check for changes to the displayed album itself
            // (its existence and metadata, not its member assets).
            if let albumChanges = changeInstance.changeDetails(for: assetCollection) {
                // If album delete return
                if albumChanges.objectWasDeleted == true { return }
                // Fetch the new album and update the UI accordingly.
                viewModel.assetCollection = albumChanges.objectAfterChanges!
            }
            // Check for changes to the list of assets (insertions, deletions, moves, or updates).
            if let changes = changeInstance.changeDetails(for: viewModel.photoAssets) {
                // Keep the new fetch result for future use.
                viewModel.photoAssets = changes.fetchResultAfterChanges
                // Update datasource of images
                let sortedIndices = viewModel.indexPathsToBeDeleted.sorted { $0.row > $1.row }
                sortedIndices.forEach { indexPath in
                    viewModel.images.remove(at: indexPath.row)
                }
                viewModel.indexPathsToBeDeleted.removeAll()
                selectedIndexPaths.removeAll()
                if changes.hasIncrementalChanges {
                    // If there are incremental diffs, animate them in the collection view.
                    collectionView.performBatchUpdates({
                        // For indexes to make sense, updates must be in this order:
                        // delete, insert, reload, move
                        if let removed = changes.removedIndexes, removed.count > 0 {
                            collectionView.deleteItems(at: removed.map { IndexPath(item: $0, section:0) })
                        }
                        if let inserted = changes.insertedIndexes, inserted.count > 0 {
                            collectionView.insertItems(at: inserted.map { IndexPath(item: $0, section:0) })
                        }
                        if let changed = changes.changedIndexes, changed.count > 0 {
                            collectionView.reloadItems(at: changed.map { IndexPath(item: $0, section:0) })
                        }
                        changes.enumerateMoves { fromIndex, toIndex in
                            collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                    to: IndexPath(item: toIndex, section: 0))
                        }
                    })
                } else {
                    // Reload the collection view if incremental diffs are not available.
                    collectionView.reloadData()
                }
                updateBarRightItem()
                Loaf(viewModel.loafTitle.raw, state: .custom(.init(backgroundColor: UIColor(hexString: "#2ecc71"), icon: Loaf.Icon.success, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
                if self.viewModel.images.count == 0 {
                    self.collectionView?.isHidden = true
                    self.noAssetsView.isHidden = false
                }
            }
        }
    }
}
