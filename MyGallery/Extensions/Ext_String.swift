//
//  Ext_String.swift
//  MyGallery
//
//  Created by Christos Petimezas on 25/6/21.
//

import Foundation
import UIKit

extension String {
    
    func withReplacedCharacters(_ oldChar: String, by newChar: String) -> String {
        let newStr = self.replacingOccurrences(of: oldChar, with: newChar, options: .literal, range: nil)
        return newStr
    }
    
    func image() -> UIImage? {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 35)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func localized() -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
}
