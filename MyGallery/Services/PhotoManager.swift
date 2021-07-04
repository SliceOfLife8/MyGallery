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
    
    init() {
        self.nsCache.totalCostLimit = 100 * 1024 * 1024 // Here the size in bytes of data is used as the cost, here 100 MB limit
    }
    
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
