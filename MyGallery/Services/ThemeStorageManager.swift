//
//  ThemeStorageManager.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 27/10/21.
//

import CoreData
import UIKit

/// #Images are provided from https://imgbb.com/

enum ThemeNames: String, CaseIterable {
    case dream = "dream"
    case flowers = "flowers"
    case mountainUniverse = "mountain_universe"
    case reborn = "reborn"
    case rose = "rose"
    case shingle = "shingle"
    case tech = "tech"
    case universe = "universe"
}

enum ThemeKeys: String, CaseIterable {
    case dream = "wSpy9cm"
    case flowers = "r4sqfpj"
    case mountainUniverse = "hBwQ6Tw"
    case reborn = "6sddyhv"
    case rose = "MVZstRx"
    case shingle = "nm2MZvm"
    case tech = "vqYTkCj"
    case universe = "pfDFhYx"
}

class ThemeStorageManager {

    static let shared = ThemeStorageManager()

    var availableImages: [String] = ThemeNames.allCases.map { $0.rawValue }
    var imageURLs: [URL?] = []

    func retrieve() {
        // Create a reference to the file you want to download
        for (index, element) in availableImages.enumerated() {
            guard let key = ThemeKeys.allCases[safe: index]?.rawValue else { return }

            let constructUrl = URL(string: AppConfig.imgbbDomain + key + "/\(element).jpg")
            imageURLs.append(constructUrl)
        }
    }

    // Retrieve background Image
    func retrieveGalleryImage() -> (image: UIImage?, key: ThemeNames?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return (UIImage(named: "Pattern"), .none)
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GalleryBackground")

        do {
            let request = try managedContext.fetch(fetchRequest)

            if let imageData = request.first?.value(forKey: "image") as? Data,
               let key = request.first?.value(forKey: "key") as? String {
                return (UIImage(data: imageData), ThemeNames(rawValue: key))
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return (UIImage(named: "Pattern"), .none)
    }

    func saveGalleryImage(key: ThemeNames?, image: UIImage?) {
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
