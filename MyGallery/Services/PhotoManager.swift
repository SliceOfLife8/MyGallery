//
//  PhotoManager.swift
//  MyGallery
//
//  Created by Christos Petimezas on 28/6/21.
//

import UIKit

class PhotoManager {
    
    static let shared = PhotoManager()
    
    var nsCache = NSCache<NSString, UIImage>()
    
    func storeImage(_ image: UIImage?, for key: String) {
        let formattedKey = key as NSString
        guard let storedImage = image, nsCache.object(forKey: formattedKey) == nil else { return }
        self.nsCache.setObject(storedImage, forKey: formattedKey)
    }
    
    func retrieveImage(with key: String) -> UIImage? {
        let formattedKey = key as NSString
        let storedImage = self.nsCache.object(forKey: formattedKey)
        return storedImage
    }
    
}
