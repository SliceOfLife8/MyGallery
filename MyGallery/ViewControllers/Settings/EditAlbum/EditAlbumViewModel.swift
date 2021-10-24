//
//  EditAlbumViewModel.swift
//  MyGallery
//
//  Created by Christos Petimezas on 29/6/21.
//

import Foundation
import Photos

enum InfoMessages: String {
    case deleteAlbum
    case deleteMultipleImages
    case deleteSingleImage
    case deleteMultipleImagesFromAlbum
    case deleteSingleImageFromAlbum
    
    var raw: String {
        switch self {
        case .deleteAlbum:
            return "album_deleted".localized()
        case .deleteMultipleImages:
            return "delete_multiple_images".localized()
        case .deleteSingleImage:
            return "delete_single_image".localized()
        case .deleteMultipleImagesFromAlbum:
            return "delete_multiple_images_fr_album".localized()
        case .deleteSingleImageFromAlbum:
            return "delete_single_image_fr_album".localized()
        }
    }
}

protocol EditAlbumVMDelegate: AnyObject {
    func didDeleteAlbum(status: Bool)
    func cleanData()
}

class EditAlbumViewModel {
    
    weak var delegate: EditAlbumVMDelegate?

    var indexPathsToBeDeleted: [IndexPath] = []
    var loafTitle: InfoMessages = .deleteMultipleImagesFromAlbum
    
    init() {}
    
    // Delete image directly from 'Collection'
    func deleteImages(indexPaths: [IndexPath]?) {
        guard let paths = indexPaths else { return }
        if paths.count == PhotoService.shared.photoAssets.count {
            self.delegate?.cleanData()
        }
        var photoAssets: [PHAsset] = []
        indexPathsToBeDeleted = paths
        paths.forEach { indexPath in
            photoAssets.append(PhotoService.shared.photoAssets.object(at: indexPath.row))
        }
        loafTitle = (paths.count == 1) ? .deleteSingleImage : .deleteMultipleImages
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(photoAssets as NSArray)
        })
    }
    
    // Delete images only from custom album
    func deleteImagesFromAlbum(indexPaths: [IndexPath]?) {
        guard let collection = PhotoService.shared.assetCollection, let paths = indexPaths else { return }
        if paths.count == PhotoService.shared.photoAssets.count {
            self.delegate?.cleanData()
        }
        var photoAssets: [PHAsset] = []
        indexPathsToBeDeleted = paths
        paths.forEach { indexPath in
            photoAssets.append(PhotoService.shared.photoAssets.object(at: indexPath.row))
        }
        loafTitle = (paths.count == 1) ? .deleteSingleImageFromAlbum : .deleteMultipleImagesFromAlbum
        
        PHPhotoLibrary.shared().performChanges({
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection) else { return }
            let fastEnumeration = NSArray(array: photoAssets)
            albumChangeRequest.removeAssets(fastEnumeration)
        }, completionHandler: nil)
    }
    
    // Delete entire collection aka Custom album & delete coreData
    func deleteAlbum() {
        self.delegate?.cleanData()
        guard let collection = PhotoService.shared.assetCollection else { return }
        let fastEnumeration = NSArray(array: [collection])
        loafTitle = .deleteAlbum
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.deleteAssetCollections(fastEnumeration)
        }, completionHandler: { (success, error) in
            if let _ = error {
                self.delegate?.didDeleteAlbum(status: false)
            } else if success {
                self.delegate?.didDeleteAlbum(status: true)
            }
        })
    }
    
}
