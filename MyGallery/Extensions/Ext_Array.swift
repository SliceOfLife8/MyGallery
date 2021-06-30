//
//  Ext_Array.swift
//  MyGallery
//
//  Created by Christos Petimezas on 30/6/21.
//

import Foundation

extension Array where Element: Equatable {
    
    func find(element: (Element) -> Bool) -> Int? {
        for (idx, elem) in self.enumerated() {
            if element(elem) {
                return idx
            }
        }
        return nil
    }
    
}
