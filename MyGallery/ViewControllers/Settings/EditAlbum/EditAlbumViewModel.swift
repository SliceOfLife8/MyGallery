//
//  EditAlbumViewModel.swift
//  MyGallery
//
//  Created by Christos Petimezas on 29/6/21.
//

import Foundation
import UIKit
import Photos

protocol EditAlbumVMDelegate: AnyObject {
    func didGetImages()
}

class EditAlbumViewModel {
    
    weak var delegate: EditAlbumVMDelegate?
    
    private var assetCollection: PHAssetCollection?
    var images: [UIImage] = []
    var photoAssets = PHFetchResult<PHAsset>()
    
    init() {}
    
    func fetchCustomAlbumPhotos() {
        var albumFound = Bool()
        
        assetCollection = CustomPhotoAlbum.fetchAssetCollectionForAlbum()
        albumFound = (assetCollection != nil) ? true : false
        
        guard albumFound == true, let myCollection = assetCollection else { return }
        photoAssets = PHAsset.fetchAssets(in: myCollection, options: nil)
        let imageManager = PHCachingImageManager()
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
            print("imagecount: \(images.count)")
            self.delegate?.didGetImages()
        }
    }
    
    // Delete image directly from 'Collection'
    func deleteImage(index: Int) {
        let photoAsset = self.photoAssets.object(at: index)
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([photoAsset] as NSArray)
        })
    }
    
    // Delete images only from custom album
    func deleteImagesFromAlbum(index: Int) {
        guard let collection = assetCollection else { return }
        let photoAsset = self.photoAssets.object(at: index)
        
        PHPhotoLibrary.shared().performChanges({
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection) else { return }
            let fastEnumeration = NSArray(array: [photoAsset])
            albumChangeRequest.removeAssets(fastEnumeration)
        }, completionHandler: { success, error in
            if success {
                print("removed")
            } else {
                print("not removed")
            }
        })
    }
    
    // Delete entire collection aka Custom album
    func deleteAlbum() {
        guard let collection = assetCollection else { return }
        let fastEnumeration = NSArray(array: [collection])
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.deleteAssetCollections(fastEnumeration)
        }, completionHandler: { (success, error) in
            if success {
                //success
            } else if let error = error {
                //failed
            }
        })
    }
    
}
