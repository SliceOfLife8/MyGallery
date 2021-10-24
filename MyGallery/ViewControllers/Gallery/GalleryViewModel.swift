//
//  GalleryViewModel.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import Foundation

protocol GalleryVMDelegate: AnyObject {
    func didGetImages()
}

class GalleryViewModel {
    
    weak var delegate: GalleryVMDelegate?
    
    var photos: [Photo] = []
    var images: [URL?] = []
    var page: Int = UserDefaults.standard.value(forKey: "Page") as? Int ?? 1
    var hasNext: Bool = false
    var numberOfImagesBatch: Int = 10
    
    init() {}
    
    func getImages() {
        let pageAsString = String(page)
        MediaContext.dataRequest(with: "https://api.pexels.com/v1/curated?page=\(pageAsString)&per_page=\(numberOfImagesBatch)", objectType: Curated.self) { (result: Result) in
            switch result {
            case .success(let object):
                /// Check if there is a corresponding page
                self.hasNext = (object.nextPage == nil) ? false : true
                if self.hasNext == false {
                    UserDefaults.standard.set(1, forKey: "Page") /// restore value
                    return
                }
                self.photos.append(contentsOf: object.photos)
                self.page += 1
                self.addImagesURL(object.photos)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// #Retrieve public URLs
    private func addImagesURL(_ photos: [Photo]) {
        photos.forEach { element in
            self.images.append(URL(string: element.src.large))
        }
        self.delegate?.didGetImages()
        UserDefaults.standard.set(page, forKey: "Page")
    }
    
}
