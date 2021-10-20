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

    static func syncSettingsBundle() {
        if let bundlePath = Bundle.main.path(forResource: "Settings", ofType: "bundle"),
           let plistPath = URL(string: bundlePath)?.appendingPathComponent("Root.plist").absoluteString {

            let defaultDefaults = UserDefaults.defaultsForPlist(path: plistPath, defaults: [:])
            UserDefaults.standard.register(defaults: defaultDefaults)
        }
    }

    static private func defaultsForPlist(path: String, defaults: [String: Any]) -> [String: Any] {
        var mutableDefaults = defaults
        if let plistXML = FileManager.default.contents(atPath: path) {
            do {
                let plistData = try PropertyListSerialization.propertyList(from: plistXML,
                                                                           options: .mutableContainersAndLeaves,
                                                                           format: nil) as! [String:AnyObject]
                if let prefs = plistData["PreferenceSpecifiers"] as? Array<[String: Any]> {
                    prefs.forEach { (pref: [String : Any]) in
                        if let key = pref["Key"] as? String,
                           let value = pref["DefaultValue"] {
                            mutableDefaults[key] = value
                        } else if let type = pref["Type"] as? String,
                                  type == "PSChildPaneSpecifier",
                                  let file = pref["File"] as? String,
                                  let childPath = URL(string: path)?
                                    .deletingLastPathComponent()
                                    .appendingPathComponent(file)
                                    .absoluteString {
                            mutableDefaults = UserDefaults.defaultsForPlist(path: childPath, defaults: mutableDefaults)
                        }
                    }
                } else {
                    print("Error no PreferenceSpecifiers in \(path)")
                }
            } catch {
                print("Error reading plist: \(error) in \(path)")
            }
        } else {
            print("No plist found found at \(path)")
        }
        return mutableDefaults
    }
    
}
