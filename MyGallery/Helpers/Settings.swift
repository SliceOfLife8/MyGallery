//
//  Settings.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 24/10/21.
//

import Foundation

enum SettingKey: String {
    case sound = "SoundSettingState"
    case vibration = "VibrationSettingState"
}

class Settings {
    static let shared = Settings()

    func retrieveState(forKey: SettingKey) -> Bool {
        guard let soundState = UserDefaults.standard.object(forKey: forKey.rawValue) as? Bool else { return true }
        return soundState
    }

    func updateSetting(state: Bool, key: SettingKey) {
        UserDefaults.standard.set(state, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
}
