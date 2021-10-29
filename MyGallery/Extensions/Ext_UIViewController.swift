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

    func showLoader() {
        let alert = UIAlertController(title: nil, message: "please_wait".localized(), preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: false, completion: nil)
    }
    
}
