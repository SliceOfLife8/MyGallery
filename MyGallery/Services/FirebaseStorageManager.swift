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
    case dream = "dream"
    case flowers = "flowers"
    case mountainUniverse = "mountain_universe"
    case reborn = "reborn"
    case rose = "rose"
    case shingle = "shingle"
    case tech = "tech"
    case universe = "universe"
}

enum FirebaseError : Error {
    case storage(Int, String)
}

class FirebaseStorageManager {

    static let shared = FirebaseStorageManager()

    var availableImages: [String] = FirebaseImages.allCases.map { $0.rawValue }
    var childs: [StorageReference] = []

    func retrieve() {
        let reference = Storage.storage(url: AppConfig.firebaseStorage).reference()
        // Create a reference to the file you want to download
        availableImages.forEach { name in
            childs.append(reference.child("\(name).jpg"))
        }
    }

    // Retrieve background Image
    func retrieveGalleryImage() -> (image: UIImage?, key: FirebaseImages?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return (UIImage(named: "Pattern"), .none)
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GalleryBackground")

        do {
            let request = try managedContext.fetch(fetchRequest)

            if let imageData = request.first?.value(forKey: "image") as? Data,
               let key = request.first?.value(forKey: "key") as? String {
                return (UIImage(data: imageData), FirebaseImages(rawValue: key))
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return (UIImage(named: "Pattern"), .none)
    }

    func saveGalleryImage(key: FirebaseImages?, image: UIImage?) {
        // Save image local with coreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let imageKey = key else {
            appDelegate.deleteCoreData("GalleryBackground")
            return
        }

        guard let imageData = image?.pngData() else { return }
        // delete previous binary Data
        appDelegate.deleteCoreData("GalleryBackground")
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "GalleryBackground", in: managedContext)!
        let asset = NSManagedObject(entity: entity, insertInto: managedContext)

        asset.setValue(imageData, forKeyPath: "image")
        asset.setValue(imageKey.rawValue, forKey: "key")

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}
