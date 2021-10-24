//
//  CustomPhotoAlbum.swift
//  MyGallery
//
//  Created by Christos Petimezas on 28/6/21.
//

import Photos
import UIKit
import Loaf
import CoreData

class CustomPhotoAlbum: NSObject {
    
    static let shared = CustomPhotoAlbum()
    
    private var assetCollection: PHAssetCollection!
    private var parentVC: UIViewController!
    private var images: [NSManagedObject] = []
    
    private override init() {
        super.init()
        
        if let assetCollection = CustomPhotoAlbum.fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
    }
    
    private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool, _ status: PHAuthorizationStatus) -> Void)) {
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
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
        fetchOptions.predicate = NSPredicate(format: "title = %@", AppConfig.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage, with parentViewController: UIViewController, identifier: String?) {
        self.parentVC = parentViewController
        fetchingFromCoreData()

        for (_, image) in images.enumerated() {
            if let element = image.value(forKey: "identifier") as? String,  element == identifier {
                showWarning()
                return
            }
        }

        self.checkAuthorizationWithHandler { [self] (success, status) in
            if status == .limited  {
                DispatchQueue.main.async {
                    self.saveContext(attribute: identifier)
                    self.showLimitedAccessAlert(self.parentVC, image: image)
                }
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
                    NotificationCenter.default.post(name: .didAlbumCreated, object: nil)
                    DispatchQueue.main.async {
                        self.saveContext(attribute: identifier)
                    }
                } else {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: AppConfig.albumName)   // create an asset collection with the album name
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
            } else {
                DispatchQueue.main.async {
                    self.showDeniedAccessAlert(parentVC)
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
                Loaf("Error with description: \(error.localizedDescription)", state: .custom(.init(backgroundColor: UIColor(named: "Red")!, icon: Loaf.Icon.error, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self.parentVC).show(.short)
            } else {
                Loaf("image_saved".localized(), state: .custom(.init(backgroundColor: UIColor(hexString: "#2ecc71"), icon: Loaf.Icon.success, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self.parentVC).show(.short)
            }
        }
    }

    fileprivate func showWarning() {
        DispatchQueue.main.async {
            Loaf("already_fetched".localized(), state: .custom(.init(backgroundColor: UIColor(named: "Orange")!, icon: Loaf.Icon.warning, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self.parentVC).show(.short)
        }
    }

    private func saveContext(attribute: String?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Asset", in: managedContext)!
        let asset = NSManagedObject(entity: entity, insertInto: managedContext)

        asset.setValue(attribute, forKeyPath: "identifier")

        do {
            try managedContext.save()
            images.append(asset)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    private func fetchingFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Asset")

        do {
            images = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

}

// MARK: - Show Alert Dialogs
extension CustomPhotoAlbum {

    private func showLimitedAccessAlert(_ viewController: UIViewController, image: UIImage) {
        if UserDefaults.standard.bool(forKey: "photo_alertDialog") { return }
        let alert = UIAlertController(title: "limited_alert_title".localized(), message: "limited_alert_message".localized(), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "settings".localized(), style: .default, handler: { action in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }))
        alert.addAction(UIAlertAction(title: "limited_alert_not_asked_again".localized(), style: .destructive, handler: { action in
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            UserDefaults.standard.set(true, forKey: "photo_alertDialog")
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { action in
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }))

        viewController.present(alert, animated: true, completion: nil)
    }

    private func showDeniedAccessAlert(_ viewController: UIViewController) {
        let alert = UIAlertController(title: "denied_alert_title".localized(), message: "denied_alert_message".localized(), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "settings".localized(), style: .default, handler: { action in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel))

        viewController.present(alert, animated: true, completion: nil)
    }

}
