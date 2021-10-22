//
//  Ext_Equatable.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 22/10/21.
//

import Foundation

extension Equatable {
    func oneOf(other: Self...) -> Bool {
        return other.contains(self)
    }
}
