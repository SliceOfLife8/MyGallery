//
//  SettingsBundleHelper.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 20/10/21.
//

import Foundation

struct SettingsBundleHelper {

    static func hqEnabled() -> Bool {
        // Sync userDefaults before getting the value because user maybe toggle HQ switch in run-time.
        UserDefaults.syncSettingsBundle()
        return UserDefaults.standard.bool(forKey: "hq_preference")
    }

}
