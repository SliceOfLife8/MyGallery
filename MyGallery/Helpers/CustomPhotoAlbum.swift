//
//  CustomPhotoAlbum.swift
//  MyGallery
//
//  Created by Christos Petimezas on 28/6/21.
//

import Photos
import UIKit
import Loaf

class CustomPhotoAlbum: NSObject {
    
    static let albumName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    static let shared = CustomPhotoAlbum()
    
    private var assetCollection: PHAssetCollection!
    private var parentVC: UIViewController!
    
    private override init() {
        super.init()
        
        if let assetCollection = CustomPhotoAlbum.fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
    }
    
    private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool, _ status: PHAuthorizationStatus) -> Void)) {
        var status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            // Fallback on earlier versions
            status = PHPhotoLibrary.authorizationStatus()
        }
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                self.checkAuthorizationWithHandler(completion: completion)
            })
        }
        else if status == .authorized {
            completion(true, status)
        } else {
            completion(false, status)
        }
    }
    
    static func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage, with parentViewController: UIViewController) {
        self.parentVC = parentViewController
        self.checkAuthorizationWithHandler { (success, status) in
            if #available(iOS 14, *), status == .limited  {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                return
            }
            if success {
                if let assetCollection = CustomPhotoAlbum.fetchAssetCollectionForAlbum() {
                    // Album already exists
                    self.assetCollection = assetCollection
                    PHPhotoLibrary.shared().performChanges({
                        let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                        let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                        let enumeration: NSArray = [assetPlaceHolder!]
                        albumChangeRequest!.addAssets(enumeration)
                        
                    }, completionHandler: nil)
                    self.showInfoMessages(with: nil)
                } else {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)   // create an asset collection with the album name
                    }) { success, error in
                        if success {
                            self.assetCollection = CustomPhotoAlbum.fetchAssetCollectionForAlbum()
                            PHPhotoLibrary.shared().performChanges({
                                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                                let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                                let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                                let enumeration: NSArray = [assetPlaceHolder!]
                                albumChangeRequest!.addAssets(enumeration)
                                
                            }, completionHandler: nil)
                        } else {
                            // Unable to create album
                        }
                        self.showInfoMessages(with: error)
                    }
                }
            }
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        self.showInfoMessages(with: error)
    }
    
    fileprivate func showInfoMessages(with error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                Loaf("Error with description: \(error.localizedDescription)", state: .custom(.init(backgroundColor: UIColor(named: "RedColor")!, icon: Loaf.Icon.error, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self.parentVC).show(.short)
            } else {
                Loaf("image_saved".localized(), state: .custom(.init(backgroundColor: UIColor(hexString: "#2ecc71"), icon: Loaf.Icon.success, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self.parentVC).show(.short)
            }
        }
    }
}
