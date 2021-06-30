//
//  EditCustomAlbum+UICollectionView.swift
//  MyGallery
//
//  Created by Christos Petimezas on 30/6/21.
//

import UIKit

// MARK: - UICollectionView Delegates
extension EditCustomAlbumVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func setupCollectionView() {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = minimumItemSpacingAtSameRow
        collectionViewFlowLayout.minimumInteritemSpacing = minimumItemSpacingBetweenGrids
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: minimumItemSpacingBetweenGrids, left: 0, bottom: 0, right: 16)
        let itemSize = estimateSizeOfImages()
        collectionViewFlowLayout.itemSize = CGSize(width: itemSize.width, height: itemSize.height)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.addExclusiveConstraints(superview: view, top: (view.safeAreaLayoutGuide.topAnchor, 24), bottom: (view.bottomAnchor, 0), left: (view.leadingAnchor, 16), right: (view.trailingAnchor, 0))
        
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .clear
        self.collectionView = collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    /// #Estimate size of images depending on default paddings
    internal func estimateSizeOfImages() -> CGSize {
        let _numberOfElementsInRow = CGFloat(numberOfElementsInRow)
        let allWidthBetwenCells = _numberOfElementsInRow == 0 ? 0 : minimumItemSpacingAtSameRow * (_numberOfElementsInRow - 1)
        let standardPaddings: CGFloat = (16 * 2) + allWidthBetwenCells // 16 -> leading & trailing
        let remainingWidth = screenWidth - standardPaddings
        let imageSize = CGSize(width: remainingWidth / _numberOfElementsInRow, height: remainingWidth / _numberOfElementsInRow)
        
        return imageSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GalleryCell
        
        cell.imageView?.image = viewModel.images[indexPath.row]
        
        if let index = self.selectedIndexPaths.find(element: { $0 == indexPath }) {
            cell.createCircle(with: index + 1)
        }
        
        return cell
    }
    
    /*
     - Deselect items & update datasource of selectedIndexPaths
     - Reload items when it's necessary. This is important when we have f.e. 3 visible & selected cells ( circle indicators 1, 2, 3) and we decide to deselect cell 2. We have to update indicators, so in order to achieve that we force collectionView to performBatchUpdates to certain indexPaths.
     */
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            if selectedItems.contains(indexPath) {
                collectionView.deselectItem(at: indexPath, animated: true)
                selectedIndexPaths = selectedIndexPaths.filter { $0 != indexPath }
                updateCertainIndexPaths(selectedIndexPaths)
                updateBarRightItem()
                return false
            }
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath) as? GalleryCell {
            let selectedItems = collectionView.indexPathsForSelectedItems?.count ?? 0
            cell.createCircle(with: selectedItems + 1)
            selectedIndexPaths.append(indexPath)
            updateBarRightItem()
        }
        return true
    }
    
    func updateCertainIndexPaths(_ indexPaths: [IndexPath]) {
        for (index, item) in indexPaths.enumerated() {
            collectionView?.performBatchUpdates({
                if let myCell = self.collectionView?.cellForItem(at: item) as? GalleryCell {
                    myCell.createCircle(with: index + 1)
                }
            }, completion: nil)
        }
    }
    
    func getAllIndexPaths() -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        guard let cv = collectionView else { return indexPaths }
        
        for s in 0..<cv.numberOfSections {
            for i in 0..<cv.numberOfItems(inSection: s) {
                indexPaths.append(IndexPath(item: i, section: s))
            }
        }
        return indexPaths
    }
}