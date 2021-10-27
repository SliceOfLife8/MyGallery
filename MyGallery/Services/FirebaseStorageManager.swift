//
//  FirebaseStorageManager.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 27/10/21.
//

import CoreData
import FirebaseStorage
import FirebaseAnalytics

enum FirebaseImages: String, CaseIterable {
    case desert = "desert"
    case forest = "forest"
    case mountain = "mountain"
    case sea = "sea"
    case sunset = "sunset"
    case universe = "universe"
}

class FirebaseStorageManager {

    static let shared = FirebaseStorageManager()

    var images: [String: UIImage] = [:]
    var errorCode: StorageErrorCode?
    private var availableImagesName: [String] = FirebaseImages.allCases.map { $0.rawValue }

    func retrieve() {
        let reference = Storage.storage(url: AppConfig.firebaseStorage).reference()
        // Create a reference to the file you want to download
        availableImagesName.forEach { name in
            let child = reference.child("\(name).jpg")
            downloadImage(key: name, reference: child)
        }
    }

    private func downloadImage(key: String, reference: StorageReference) {
        // Download in memory with a maximum allowed size of 10MB (10 * 1024 * 1024 bytes)
        reference.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error as NSError? {
                if let code = StorageErrorCode(rawValue: error.code) {
                    Analytics.logEvent("storageManager error", parameters: [
                        "code": code
                    ])
                }
            } else {
                if let _data = data, let image = UIImage(data: _data) {
                    self.images[key] = image
                }
            }
        }
    }

    // Retrieve background Image
    func retrieveGalleryImage() -> (image: UIImage?, defaultImage: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return (UIImage(named: "Pattern"), true)
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GalleryBackground")

        do {
            let request = try managedContext.fetch(fetchRequest)
            if let imageData = request.first?.value(forKey: "image") as? Data {
                return (UIImage(data: imageData), false)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return (UIImage(named: "Pattern"), true)
    }

    func saveGalleryImage(key: FirebaseImages?) {
        // Save image local with coreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let imageKey = key else {
            appDelegate.deleteCoreData("GalleryBackground")
            return
        }

        guard let imageData = images[imageKey.rawValue]?.pngData() else { return }
        // delete previous binary Data
        appDelegate.deleteCoreData("GalleryBackground")
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "GalleryBackground", in: managedContext)!
        let asset = NSManagedObject(entity: entity, insertInto: managedContext)

        asset.setValue(imageData, forKeyPath: "image")

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    // how to update values
    // FirebaseStorageManager.shared.saveGalleryImage(key: .universe)
    // NotificationCenter.default.post(name: .didGalleryBGImageChanged, object: nil)

}
