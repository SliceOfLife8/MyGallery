//
//  HomeVC.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import UIKit

class HomeVC: UIViewController {
    
    var photos: [Photo] = []
    var images: [Int:UIImage] = [:]
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
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
        dataRequest(with: "https://api.pexels.com/v1/curated?page=2", objectType: Curated.self) { (result: Result) in
            switch result {
            case .success(let object):
                print(object)
                self.photos.append(contentsOf: object.photos)
                self.addImagesURL { [weak self] in
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// #Retrieve images from public urls
    private func addImagesURL(_ completion: @escaping () -> Void) {
        for (index, element) in photos.enumerated() {
            if let url = URL(string: element.src.medium) {
                UIImage.loadFrom(url: url) { image in
                    self.images[index] = image
                    if self.images.count == self.photos.count {
                        completion()
                    }
                }
            }
        }
    }
    
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath as IndexPath) as! PhotoCell
        cell.setupCell(images[indexPath.item], photographerName: self.photos[indexPath.item].photographer)
        return cell
    }
    
}

extension HomeVC: PinterestLayoutDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        
        let height = images[indexPath.item]?.size.height ?? 250
        return height
    }
}
