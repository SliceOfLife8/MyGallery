//
//  PhotoService.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 23/10/21.
//

import UIKit
import Photos

/// #This class is used for fetching assets from a specific album
protocol PhotoServiceDelegate: AnyObject {
    func didGetImages()
}

class PhotoService {

    static let shared = PhotoService()
    weak var delegate: PhotoServiceDelegate?

    var _assetCollection: PHAssetCollection?
    var assetCollection: PHAssetCollection? {
        get {
           return CustomPhotoAlbum.fetchAssetCollectionForAlbum()
        }
        set {
            self._assetCollection = newValue
        }
    }
    var images: [UIImage] = []
    var photoAssets = PHFetchResult<PHAsset>()

    func fetchCustomAlbumPhotos() {
        var albumFound = Bool()
        restoreData()

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

    func fetchAssets() {
        restoreData()
        guard let myCollection = assetCollection else { return }

        photoAssets = PHAsset.fetchAssets(in: myCollection, options: nil)
    }

    private func addImages(uploadImage: UIImage, totalAssets: Int) {
        self.images.append(uploadImage)
        if totalAssets == images.count {
            self.delegate?.didGetImages()
        }
    }

    private func restoreData() {
        images = []
        photoAssets = PHFetchResult<PHAsset>()
    }

}
