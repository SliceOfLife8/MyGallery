//
//  MediaContextUnitTests.swift
//  MyGalleryTests
//
//  Created by Christos Petimezas on 4/7/21.
//

@testable import PicsWall
import XCTest

class MediaContextUnitTests: XCTestCase {

    var apiManager: MediaContext!
    
    override func setUp() {
        super.setUp()
        //apiManager = MediaContext
    }
    
    override func tearDown() {
        apiManager = nil
        super.tearDown()
    }
    
    func test_connection() {
        let urlAsString = "https://api.pexels.com/v1/curated?page=1&per_page=10"
        let expectation = XCTestExpectation.init(description: "Get \(urlAsString)")
        MediaContext.dataRequest(with: urlAsString, objectType: Curated.self) { (result: Result) in
            
            //XCTAssert(result == "ok", "result is not successed")
        }
    }

}
