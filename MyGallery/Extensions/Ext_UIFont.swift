//
//  Ext_UIFont.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 22/10/21.
//

import UIKit

extension UIFont {
    static func systemFontItalic(size fontSize: CGFloat = 17.0, fontWeight: UIFont.Weight = .regular) -> UIFont {
        let font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        return UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitItalic)!, size: fontSize)
    }
}
