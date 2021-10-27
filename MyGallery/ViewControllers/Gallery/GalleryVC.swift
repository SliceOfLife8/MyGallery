//
//  GalleryVC.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import UIKit
import Loaf

class GalleryVC: BaseVC {
    
    // MARK: - Vars
    private(set) var viewModel: GalleryViewModel
    private var collectionViewIsUpdating = false
    var sharedImage: UIImage?
    var sharedImageInfo: (sizePerMb: String, photographer: String)?
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Init
    init(_ viewModel: GalleryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        configure(viewModel: viewModel)
    }
    
    func configure(viewModel: GalleryViewModel) {
        viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.barStyle = .black
        setupBGImage()
        setupCollectionView()
        populateData()
        StoreReviewHelper.checkAndAskForReview()
        NotificationCenter.default.addObserver(self, selector: #selector(setupBGImage), name: .didGalleryBGImageChanged, object: nil)
    }
    
    override func languageDidChange() {
        super.languageDidChange()
        self.collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        let layout = PinterestLayout()
        collectionView.collectionViewLayout = layout
        layout.invalidateLayout()
        layout.delegate = self

        collectionView?.backgroundColor = .clear
        collectionView?.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 10, right: 16)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
    }
    
    private func populateData() {
        viewModel.getImages()
    }

    @objc func setupBGImage() {
        view.backgroundColor = nil // reset values
        view.layer.contents = nil
        let retrieve = FirebaseStorageManager.shared.retrieveGalleryImage()

        if let patternImage = retrieve.image {
            if retrieve.defaultImage {
                view.backgroundColor = UIColor(patternImage: patternImage)
            } else {
                view.layer.contents = patternImage.cgImage
            }
        }
    }
    
}

extension GalleryVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath as IndexPath) as! PhotoCell
        if viewModel.images.count == 0 || viewModel.photos.count == 0 { return cell }
        cell.setupCell(viewModel.images[indexPath.item], photographerName: viewModel.photos[indexPath.item].photographer)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell,
              let selectedImage = cell.imageView.image
        else { return }
        /// #Custom transition to ImagePreview
        let imageInfo = ImageInfo(image: selectedImage, imageMode: .aspectFit, imageHD: URL(string: viewModel.photos[indexPath.item].src.original), authorName: viewModel.photos[indexPath.item].photographer, authorURL: URL(string: viewModel.photos[indexPath.item].photographerURL))
        let transitionInfo = TransitionInfo(fromView: cell)
        let imageViewer = ImagePreviewVC(imageInfo: imageInfo, transitionInfo: transitionInfo)
        imageViewer.delegate = self
        imageViewer.modalPresentationStyle = .overFullScreen
        present(imageViewer, animated: true, completion: nil)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard collectionViewIsUpdating == false && viewModel.hasNext == true else { return }
        
        if targetContentOffset.pointee.y >= (collectionView.contentSize.height - collectionView.frame.size.height) - 350*2 {
            collectionViewIsUpdating = true
            viewModel.getImages()
        }
    }
    
}

extension GalleryVC: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        //let height = viewModel.images[indexPath.item]?.size.height ?? 250
        return 350
    }
}

extension GalleryVC: GalleryVMDelegate {
    func didGetImages() {
        collectionViewIsUpdating = false
        DispatchQueue.main.async {
            self.sendAnalytics()
            self.collectionView.reloadData()
            if self.viewModel.page == 2 {
                Loaf("photos_by_pexels".localized(), state: .custom(.init(backgroundColor: UIColor(named: "DarkGray")!, icon: nil, textAlignment: .center)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
            }
        }
    }
}

extension GalleryVC: ImagePreviewDelegate {
    func didShareImage(with image: UIImage?, size: String, photographer: String) {
        self.sharedImage = image
        self.sharedImageInfo = (size, photographer)
        self.shareImage(presentOverModal: true)
    }
    
    func didStoreImage(for image: UIImage?, attribute: String?) {
        self.sharedImage = image
        self.downloadAsset(for: image, presentOverModal: true, attribute: attribute)
    }
}
