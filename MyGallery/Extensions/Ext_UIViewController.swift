//
//  Ext_UIViewController.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 24/10/21.
//

import UIKit

extension UIViewController {

    func playMusicIfEnabled(_ key: SoundKey) {
        if Settings.shared.retrieveState(forKey: .sound) {
            Settings.shared.playSound(key)
        }
    }
    
}
