//
//  FirebaseStorageManager.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 27/10/21.
//

import Foundation
import FirebaseStorage
import FirebaseAnalytics

class FirebaseStorageManager {

    static let shared = FirebaseStorageManager()

    var images: [UIImage] = []
    var errorCode: StorageErrorCode?

    func retrieve() {
        let reference = Storage.storage(url: AppConfig.firebaseStorage).reference()
        // Create a reference to the file you want to download
        let child = reference.child("desert.jpg")


        // Download in memory with a maximum allowed size of 10MB (10 * 1024 * 1024 bytes)
        child.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error as NSError? {
                if let code = StorageErrorCode(rawValue: error.code) {
                    Analytics.logEvent("storageManager error", parameters: [
                        "code": code
                    ])
                }
            } else {
                if let _data = data, let image = UIImage(data: _data) {
                    self.images.append(image)
                }
            }
        }
    }

//    func retrieveGalleryImage() -> UIImage {
//        // Retrieve background Image
//    }

    func saveGalleryImage() {
        // Save image local with coreData
    }

}
