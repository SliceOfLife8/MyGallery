//
//  HomeVC.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import UIKit

class HomeVC: UIViewController {
    
    // MARK: - Vars
    private(set) var viewModel: HomeViewModel
    private var collectionViewIsUpdating = false
    var sharedImage: UIImage?
    var sharedImageInfo: (sizePerMb: String, photographer: String)?
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Init
    init(_ viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        configure(viewModel: viewModel)
    }
    
    func configure(viewModel: HomeViewModel) {
        viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.barStyle = .black
        setupCollectionView()
        populateData()
    }
    
    private func setupCollectionView() {
        let layout = PinterestLayout()
        collectionView.collectionViewLayout = layout
        layout.invalidateLayout()
        layout.delegate = self
        
        if let patternImage = UIImage(named: "Pattern") {
            view.backgroundColor = UIColor(patternImage: patternImage)
        }
        collectionView?.backgroundColor = .clear
        collectionView?.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 10, right: 16)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
    }
    
    private func populateData() {
        viewModel.getImages()
    }
    
}

extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath as IndexPath) as! PhotoCell
        if viewModel.images.count == 0 || viewModel.photos.count == 0 { return cell }
        cell.setupCell(viewModel.images[indexPath.item], photographerName: viewModel.photos[indexPath.item].photographer)
        // Create a UIContextMenuInteraction with UIContextMenuInteractionDelegate
        if cell.interactions.isEmpty {
            let interaction = UIContextMenuInteraction(delegate: self)
            // Attach It to Our View
            cell.addInteraction(interaction)
        }
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard collectionViewIsUpdating == false && viewModel.hasNext == true else { return }
        
        if targetContentOffset.pointee.y >= (collectionView.contentSize.height - collectionView.frame.size.height) - 100 {
            collectionViewIsUpdating = true
            viewModel.getImages()
        }
    }
    
}

extension HomeVC: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        
        let height = viewModel.images[indexPath.item]?.size.height ?? 250
        return height
    }
}

extension HomeVC: HomeVMDelegate {
    func didGetImages() {
        collectionViewIsUpdating = false
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}