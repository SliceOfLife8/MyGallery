//
//  Ext_UserDefaults.swift
//  MyGallery
//
//  Created by Christos Petimezas on 29/6/21.
//

import UIKit

extension UserDefaults {
    
    static let appOpenedNo = "app_openned"
    static let reviewRequestNo = "review_requested"
    
    var overridedUserInterfaceStyle: UIUserInterfaceStyle {
        get {
            UIUserInterfaceStyle(rawValue: integer(forKey: #function)) ?? .unspecified
        }
        set {
            set(newValue.rawValue, forKey: #function)
        }
    }
    
}
