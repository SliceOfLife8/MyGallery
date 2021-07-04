//
//  ServicesUnitTests.swift
//  MyGalleryTests
//
//  Created by Christos Petimezas on 4/7/21.
//

@testable import PicsWall
import XCTest

class ServicesUnitTests: XCTestCase {

    var photoManager: PhotoManager!
    let images: [String] = ["no-results", "Pattern", "search-images"]
    
    override func setUp() {
        super.setUp()
        photoManager = PhotoManager()
    }
    
    override func tearDown() {
        photoManager = nil
        super.tearDown()
    }
    
    func test_store_and_retrieve_image() {
        let randomString = UUID().uuidString
        let randomImage = UIImage(named: images.randomElement() ?? "")
        photoManager.storeImage(randomImage, for: randomString)
        let retrieveImage = photoManager.retrieveImage(with: randomString)
        
        XCTAssertEqual(randomImage, retrieveImage)
    }

}
