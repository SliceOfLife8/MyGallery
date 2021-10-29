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

    func showDeniedAccessAlert() {
        let alert = UIAlertController(title: "denied_alert_title".localized(), message: "denied_alert_message".localized(), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "settings".localized(), style: .default, handler: { action in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                self.playMusicIfEnabled(.confirm)
                UIApplication.shared.open(settingsUrl)
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { _ in
            self.playMusicIfEnabled(.cancel)
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
}
