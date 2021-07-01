//
//  EditAlbumViewModel.swift
//  MyGallery
//
//  Created by Christos Petimezas on 29/6/21.
//

import Foundation
import UIKit
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
    func didGetImages()
    func didDeleteAlbum(status: Bool)
}

class EditAlbumViewModel {
    
    weak var delegate: EditAlbumVMDelegate?
    
    var assetCollection: PHAssetCollection?
    var images: [UIImage] = []
    var photoAssets = PHFetchResult<PHAsset>()
    var indexPathsToBeDeleted: [IndexPath] = []
    var loafTitle: InfoMessages = .deleteMultipleImagesFromAlbum
    
    init() {}
    
    func fetchCustomAlbumPhotos() {
        var albumFound = Bool()
        
        assetCollection = CustomPhotoAlbum.fetchAssetCollectionForAlbum()
        albumFound = (assetCollection != nil) ? true : false
        
        guard albumFound == true, let myCollection = assetCollection else {
            self.delegate?.didGetImages()
            return
        }
        photoAssets = PHAsset.fetchAssets(in: myCollection, options: nil)
        let imageManager = PHCachingImageManager()
        if photoAssets.count == 0 {
            self.delegate?.didGetImages()
            return
        }
        photoAssets.enumerateObjects{(object: AnyObject!,
                                      count: Int,
                                      stop: UnsafeMutablePointer<ObjCBool>) in
            
            if object is PHAsset {
                let asset = object as! PHAsset
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
                                            if let _image = image {
                                                self.addImages(uploadImage: _image, totalAssets: self.photoAssets.count)
                                            }
                                          })
            }
        }
    }
    
    func addImages(uploadImage: UIImage, totalAssets: Int) {
        self.images.append(uploadImage)
        if totalAssets == images.count {
            self.delegate?.didGetImages()
        }
    }
    
    // Delete image directly from 'Collection'
    func deleteImages(indexPaths: [IndexPath]?) {
        guard let paths = indexPaths else { return }
        var photoAssets: [PHAsset] = []
        indexPathsToBeDeleted = paths
        paths.forEach { indexPath in
            photoAssets.append(self.photoAssets.object(at: indexPath.row))
        }
        loafTitle = (paths.count == 1) ? .deleteSingleImage : .deleteMultipleImages
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(photoAssets as NSArray)
        })
    }
    
    // Delete images only from custom album
    func deleteImagesFromAlbum(indexPaths: [IndexPath]?) {
        guard let collection = assetCollection, let paths = indexPaths else { return }
        var photoAssets: [PHAsset] = []
        indexPathsToBeDeleted = paths
        paths.forEach { indexPath in
            photoAssets.append(self.photoAssets.object(at: indexPath.row))
        }
        loafTitle = (paths.count == 1) ? .deleteSingleImageFromAlbum : .deleteMultipleImagesFromAlbum
        
        PHPhotoLibrary.shared().performChanges({
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection) else { return }
            let fastEnumeration = NSArray(array: photoAssets)
            albumChangeRequest.removeAssets(fastEnumeration)
        }, completionHandler: nil)
    }
    
    // Delete entire collection aka Custom album
    func deleteAlbum() {
        guard let collection = assetCollection else { return }
        let fastEnumeration = NSArray(array: [collection])
        loafTitle = .deleteAlbum
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.deleteAssetCollections(fastEnumeration)
        }, completionHandler: { (success, error) in
            self.delegate?.didDeleteAlbum(status: success)
        })
    }
    
}
