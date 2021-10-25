//
//  Settings.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 24/10/21.
//

import Foundation
import AVKit

enum SettingKey: String {
    case sound = "SoundSettingState"
    case vibration = "VibrationSettingState"
}

enum SoundKey: UInt32 {
    case confirm = 1105
    case message = 1004
    case error = 1053
    case cancel = 1050
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

    func playSound(_ key: SoundKey) {
        AudioServicesPlaySystemSound(key.rawValue)
    }
}
