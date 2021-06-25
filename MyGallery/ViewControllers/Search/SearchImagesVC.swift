//
//  SearchImagesVC.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import UIKit

class SearchImagesVC: UIViewController {
    
    // MARK: - Vars
    private(set) var viewModel: SearchViewModel
    private var collectionViewIsUpdating = false
    var sharedImage: UIImage?
    var sharedImageInfo: (sizePerMb: String, photographer: String)?
    private var query: String = ""
    var workItem: DispatchWorkItem?
    
    // MARK: - Outlets
    @IBOutlet weak var searchTF: SearchTextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var failureView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: - Init
    init(_ viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        configure(viewModel: viewModel)
    }
    
    func configure(viewModel: SearchViewModel) {
        viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor(hexString: "#999999")
        setupViews()
        setupCollectionView()
    }
    
    private func setupViews() {
        searchTF.becomeFirstResponder()
        searchTF.backgroundColor = UIColor(hexString: "#cccccc")
        searchView.applyGradient(isVertical: true, colorArray: [UIColor(hexString: "#ddd6f3"), UIColor(hexString: "#faaca8")])
        failureView.applyGradient(isVertical: true, colorArray: [UIColor(hexString: "#ddd6f3"), UIColor(hexString: "#faaca8")])
        cancelBtn.isHidden = true
        searchTF.textColor = UIColor(hexString: "#734b6d")
        searchTF.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        searchTF.delegate = self
    }
    
    private func setupCollectionView() {
        let layout = PinterestLayout()
        collectionView.collectionViewLayout = layout
        layout.invalidateLayout()
        layout.delegate = self
        collectionView?.backgroundColor = .clear
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 10, right: 8)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        collectionView.keyboardDismissMode = .onDrag
    }
    
    private func showDefaultView() {
        searchView.isHidden = false
        collectionView.isHidden = true
    }
    
    private func hideCancelBtn(_ hide: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: [], animations: {
            self.cancelBtn.isHidden = hide
            self.stackView.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        searchTF.text?.removeAll()
        searchTF.resignFirstResponder()
        showDefaultView()
        hideCancelBtn(true)
    }
    
    @objc func textChanged(_ sender: Any) {
        // Cancel any outstanding search
        self.workItem?.cancel()
        let text = searchTF.text?.trimmingCharacters(in: .whitespaces)
        if let searchTerm = text, !searchTerm.isEmpty {
            hideCancelBtn(false)
            /// #Start searching for results after a predefined delay
            // Set up a DispatchWorkItem to perform the search
            let workItem = DispatchWorkItem { [weak self] in
                self?.viewModel.getImages(query: searchTerm, resettingPagition: true)
            }
            // Run this block after 0.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
            // Keep a reference to it so it can be cancelled
            self.workItem = workItem
        } else if text != query {
            showDefaultView()
        }
    }
    
}

extension SearchImagesVC: SearchVMDelegate {
    func didGetImages(_ status: Bool, paginationJustReset: Bool) {
        DispatchQueue.main.async {
            if paginationJustReset {
                self.collectionView.setContentOffset(.zero, animated: false)
                /// #Reset collectionView height when pagination is reset
                if let layout = self.collectionView.collectionViewLayout as? PinterestLayout {
                    layout.contentHeight = .zero
                }
            }
            self.collectionView.isHidden = (status) ? false : true
            self.failureView.isHidden = (status) ? true : false
            if status {
                self.searchView.isHidden = true
                self.collectionViewIsUpdating = false
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - Pinterest & CollectionView Delegates
extension SearchImagesVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath as IndexPath) as! PhotoCell
        if viewModel.images.count == 0 || viewModel.photos.count == 0 { return cell }
        cell.setupCell(viewModel.images[indexPath.item], photographerName: viewModel.photos[indexPath.item].photographer, containerBGColor: UIColor(hexString: "#f2f2f2"))
        // Create a UIContextMenuInteraction with UIContextMenuInteractionDelegate
        if cell.interactions.isEmpty {
            let interaction = UIContextMenuInteraction(delegate: self)
            // Attach It to Our View
            cell.addInteraction(interaction)
        }
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard collectionViewIsUpdating == false && viewModel.hasNext == true, let query = searchTF.text?.trimmingCharacters(in: .whitespaces) else { return }
        
        if targetContentOffset.pointee.y >= (collectionView.contentSize.height - collectionView.frame.size.height) - 100 {
            collectionViewIsUpdating = true
            viewModel.getImages(query: query)
        }
    }
    
}

extension SearchImagesVC: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        
        let height = viewModel.images[indexPath.item]?.size.height ?? 250
        return height
    }
}

extension SearchImagesVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}