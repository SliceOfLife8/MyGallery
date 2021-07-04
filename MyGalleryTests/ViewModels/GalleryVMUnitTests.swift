//
//  GalleryVMUnitTests.swift
//  MyGalleryTests
//
//  Created by Christos Petimezas on 4/7/21.
//

@testable import PicsWall
import XCTest

class GalleryVMUnitTests: XCTestCase {

    var galleryVM: GalleryViewModel!
    
    override func setUp() {
        super.setUp()
        galleryVM = GalleryViewModel()
    }
    
    override func tearDown() {
        galleryVM = nil
        super.tearDown()
    }

}
