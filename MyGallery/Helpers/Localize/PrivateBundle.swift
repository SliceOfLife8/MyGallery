//
//  PrivateBundle.swift
//  MyGallery
//
//  Created by Christos Petimezas on 7/7/21.
//

import UIKit

private var associatedLanguageBundle: Character = "0"

class PrivateBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle: Bundle? = objc_getAssociatedObject(self, &associatedLanguageBundle) as? Bundle
        return (bundle != nil) ? (bundle!.localizedString(forKey: key, value: value, table: tableName)) : (super.localizedString(forKey: key, value: value, table: tableName))
        
    }
}

extension Bundle {
    class func setLanguage(_ language: String?) {
        var onceToken: Int = 0
        
        if (onceToken == 0) {
            object_setClass(Bundle.main, PrivateBundle.self)
        }
        onceToken = 1
        objc_setAssociatedObject(Bundle.main, &associatedLanguageBundle, (language != nil) ? Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj") ?? "") : nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
