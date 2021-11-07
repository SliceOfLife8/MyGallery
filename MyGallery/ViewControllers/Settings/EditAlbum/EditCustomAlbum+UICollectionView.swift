//
//  EditCustomAlbum+UICollectionView.swift
//  MyGallery
//
//  Created by Christos Petimezas on 30/6/21.
//

import UIKit
import Photos

// MARK: - UICollectionView Delegates
extension EditCustomAlbumVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
        collectionView.register(SelectThemeHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectThemeHeaderView.identifier)
        collectionView.register(AlbumFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: AlbumFooterView.identifier)
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .clear
        self.collectionView = collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    /// #Estimate size of images depending on default paddings
    internal func estimateSizeOfImages() -> CGSize {
        let allWidthBetwenCells = minimumItemSpacingAtSameRow * (numberOfElementsInRow - 1)
        let standardPaddings: CGFloat = (16 * 2) + allWidthBetwenCells // 16 -> leading & trailing
        let remainingSize = ((screenWidth - standardPaddings)/numberOfElementsInRow).rounded(.down)
        
        return CGSize(width: remainingSize, height: remainingSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return service.photoAssets.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SelectThemeHeaderView.identifier,
                for: indexPath) as! SelectThemeHeaderView
            headerView.setupCell(withTitle: "select_images", gradientColors: [UIColor(hexString: "#4ca1af").cgColor, UIColor(hexString: "#a6d1d8").cgColor])

            return headerView
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: AlbumFooterView.identifier,
                for: indexPath) as! AlbumFooterView
            footerView.delegate = self

            return footerView
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 70)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GalleryCell

        setImage(cell, asset: service.photoAssets[indexPath.row])
        cell.bgColor = UIColor(named: "Black")?.cgColor

        if let index = self.selectedIndexPaths.find(element: { $0 == indexPath }) {
            cell.createCircle(with: index + 1)
        }

        return cell
    }

    private func setImage(_ cell: GalleryCell, asset: PHAsset) {
        let imageManager = PHCachingImageManager()
        let imageSize = CGSize(width: asset.pixelWidth,
                               height: asset.pixelHeight)

        /* For faster performance, and maybe degraded image */
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true /// This is mandatory for iCloud images.

        imageManager.requestImage(for: asset,
                                  targetSize: imageSize,
                                  contentMode: .aspectFill,
                                  options: options,
                                  resultHandler: {
                                    (image, info) -> Void in
                                    cell.imageView?.image = image
                                  })
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

extension EditCustomAlbumVC: AlbumFooterViewDelegate {
    func footerDidTapped() {
        LightboxHelper.show()
    }
}
