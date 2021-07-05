//
//  ExtensionsUnitTests.swift
//  MyGalleryTests
//
//  Created by Christos Petimezas on 5/7/21.
//

@testable import PicsWall
import XCTest

class ExtensionsUnitTests: XCTestCase {

    let imageURL = URL(string: "https://res.cloudinary.com/practicaldev/image/fetch/s--8FNVgaC7--/c_imagga_scale,f_auto,fl_progressive,h_420,q_auto,w_1000/https://dev-to-uploads.s3.amazonaws.com/i/jlij1lpng7zusvwjmjld.jpg")
    let images: [String] = ["no-results", "Pattern", "search-images"]
    let units: [UIImage.DataUnits] = [.byte, .kilobyte, .megabyte, .gigabyte]
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    /// #Test UIImage extensions
    func test_load_from() {
        guard let url = imageURL else {
            XCTFail("Url not valid")
            return }
        var fetchedImage: UIImage?
        var imageData: Data?
        
        UIImage.loadFrom(url: url) { image in
            fetchedImage = image
            imageData = fetchedImage?.pngData()
        }
        
        wait {
            if imageData == nil {
                XCTAssertTrue(fetchedImage == nil)
            } else {
                XCTAssertNotNil(fetchedImage)
            }
        }
    }
    
    func test_image_size() {
        let randomImage = UIImage(named: images.randomElement() ?? "")
        units.forEach { unit in
            let size = randomImage?.getSizeIn(unit)
            
            var expectedSize: Double = Double(randomImage?.pngData()?.count ?? 0)
            let multiply1024 = (unit == .kilobyte) ? 1024 : (unit == .megabyte) ? 1024*1024 : (unit == .gigabyte) ? 1024*1024*1024 : 1
            expectedSize = expectedSize / Double(multiply1024)
            
            XCTAssertEqual(size, String(format: "%.2f", expectedSize))
        }
    }

}

extension XCTestCase {
    func wait(interval: TimeInterval = 1.0, completion: @escaping (() -> Void)) {
        let exp = expectation(description: "")
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            completion()
            exp.fulfill()
        }
        waitForExpectations(timeout: interval + 0.1) // add 0.1 for sure asyn after called
    }
}
