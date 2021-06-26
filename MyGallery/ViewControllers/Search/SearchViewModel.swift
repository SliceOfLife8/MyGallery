//
//  SearchViewModel.swift
//  MyGallery
//
//  Created by Christos Petimezas on 25/6/21.
//

import Foundation
import UIKit

protocol SearchVMDelegate: AnyObject {
    func didGetImages(_ status: Bool, paginationJustReset: Bool)
}

class SearchViewModel {
    
    weak var delegate: SearchVMDelegate?
    
    var photos: [Photo] = []
    var images: [Int:UIImage] = [:]
    var page: Int = 1
    var hasNext: Bool = false
    var numberOfImagesBatch: Int = 10
    
    init() {}
    
    func getImages(query: String, resettingPagition reset: Bool = false) {
        /// #Replace allWhitespaces with '&' symbol
        let formattedQuery = query.withReplacedCharacters(" ", by: "&")
        if reset {
            clearData()
        }
        MediaContext.dataRequest(with: "https://api.pexels.com/v1/search?query=\(formattedQuery)&page=\(page)&per_page=\(numberOfImagesBatch)", objectType: Curated.self) { (result: Result) in
            switch result {
            case .success(let object):
                /// Check if there is a corresponding page
                self.hasNext = (object.nextPage == nil) ? false : true
                if self.hasNext == false {
                    if reset { /// If reset is true it means that a new query defined by a user. So, we don't have response to show. Otherwise, the user has already see multiple pages and there aren't more pages to show him.
                        self.delegate?.didGetImages(false, paginationJustReset: reset)
                    }
                    return
                }
                self.photos.append(contentsOf: object.photos)
                self.page += 1
                self.addImagesURL { [weak self] in
                    self?.delegate?.didGetImages(true, paginationJustReset: reset)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // #Retrieve images from public urls
    private func addImagesURL(_ completion: @escaping () -> Void) {
        for (index, element) in photos.enumerated() {
            if let url = URL(string: element.src.large) {
                UIImage.loadFrom(url: url) { image in
                    self.images[index] = image
                    if self.images.count == self.photos.count {
                        completion()
                    }
                }
            }
        }
    }
    
    private func clearData() {
        photos.removeAll()
        images.removeAll()
        page = 1
    }
    
}
