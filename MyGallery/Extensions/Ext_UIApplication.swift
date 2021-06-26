//
//  Ext_UIApplication.swift
//  MyGallery
//
//  Created by Christos Petimezas on 26/6/21.
//

import UIKit

extension UIApplication {
    var sceneDelegate: SceneDelegate {
        get {
            return self.connectedScenes
                .first!.delegate as! SceneDelegate
        }
    }
}
