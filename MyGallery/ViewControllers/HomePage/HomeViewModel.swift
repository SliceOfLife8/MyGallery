//
//  HomeViewModel.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import Foundation
import UIKit

protocol HomeVMDelegate: AnyObject {
    func didGetImages()
}

class HomeViewModel {
    
    weak var delegate: HomeVMDelegate?
    
    var photos: [Photo] = []
    var images: [Int:UIImage] = [:]
    var page: Int = 1
    var hasNext: Bool = false
    
    init() {}
    
    func getImages() {
        let pageAsString = String(page)
        MediaContext.dataRequest(with: "https://api.pexels.com/v1/curated?page=\(pageAsString)", objectType: Curated.self) { (result: Result) in
            switch result {
            case .success(let object):
                /// Check if there is a corresponding page
                self.hasNext = (object.nextPage == nil) ? false : true
                if self.hasNext == false { return }
                self.photos.append(contentsOf: object.photos)
                self.page += 1
                self.addImagesURL { [weak self] in
                    self?.delegate?.didGetImages()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// #Retrieve images from public urls
    private func addImagesURL(_ completion: @escaping () -> Void) {
        for (index, element) in photos.enumerated() {
            if let url = URL(string: element.src.medium) {
                UIImage.loadFrom(url: url) { image in
                    self.images[index] = image
                    if self.images.count == self.photos.count {
                        completion()
                    }
                }
            }
        }
    }
    
}
