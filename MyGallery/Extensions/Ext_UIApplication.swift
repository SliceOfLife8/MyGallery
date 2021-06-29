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
    
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    static var appBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    static var versionBuild: String {
        let version = appVersion, build = appBuild
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
}
