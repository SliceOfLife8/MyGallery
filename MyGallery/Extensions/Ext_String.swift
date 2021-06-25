//
//  Ext_String.swift
//  MyGallery
//
//  Created by Christos Petimezas on 25/6/21.
//

import Foundation

extension String {
    func withReplacedCharacters(_ oldChar: String, by newChar: String) -> String {
        let newStr = self.replacingOccurrences(of: oldChar, with: newChar, options: .literal, range: nil)
        return newStr
    }
}
