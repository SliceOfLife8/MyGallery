//
//  Ext_Collection.swift
//  MyGallery
//
//  Created by Christos Petimezas on 3/7/21.
//

import Foundation

public extension Collection where Indices.Iterator.Element == Index {
    subscript(safe index: Index) -> Iterator.Element? {
     return (startIndex <= index && index < endIndex) ? self[index] : nil
   }
}
