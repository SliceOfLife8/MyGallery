//
//  AppConfig.swift
//  MyGallery
//
//  Created by Christos Petimezas on 2/7/21.
//

import Foundation
import Firebase

final class AppConfig {
    
    static var apiKey: String = ""
    static var googleKey: String = ""
    
    static var appBundleID: String {
        return path("CFBundleIdentifier")
    }
    
    static var appVersion: String {
        return path("CFBundleShortVersionString")
    }
    
    static var appBuild: String {
        return path(kCFBundleVersionKey as String)
    }
    
    static var albumName: String {
        return path("CFBundleName")
    }
    
    static func decryptApiKey() {
        do {
            let sourceData = Data(base64Encoded: "hp2NenWAvRxOqf5fHXJFB+W4ExHIBEzHafZYwVlG9YPgJ2XnTbDI/hHYQwKFoV+EDgEzpYl0nWHDrKuKh4NnWg==", options: .ignoreUnknownCharacters) ?? Data()
            let key = Data(base64Encoded: "4QD+4+iH4GKMm0MnQHaLLOTx/H+xjDJCugI13fVDrVk=", options: .ignoreUnknownCharacters) ?? Data()
            let iv = Data(base64Encoded: "pk7axU5PVCiBmB45CVy7ww==", options: .ignoreUnknownCharacters) ?? Data()
            let aes = try Encryption(key: key, iv: iv)
            let decryptedData = try aes.decrypt(sourceData)
            
            apiKey = decryptedData.base64EncodedString().fromBase64() ?? ""
        } catch {
            print("Failed")
        }
    }
    
    static func decryptGoogleKey() {
        guard let googleID = decryptGoogleAppID(), let senderID = decryptSenderID() else {
            FirebaseApp.configure()
            return
        }
        let options = FirebaseOptions(googleAppID: googleID, gcmSenderID: senderID)
        options.apiKey = decryptGoogleApiKey()
        options.projectID = "mygallery-5b7f1"
        FirebaseApp.configure(options: options)
    }
    
    static private func decryptGoogleApiKey() -> String? {
        do {
            let sourceData = Data(base64Encoded: "/nU9c02MqIPRlZywUZjAxdP5KEryHQASNrlBGg+nBXULxsitzBvAy6HR0HlZAKQb", options: .ignoreUnknownCharacters) ?? Data()
            let key = Data(base64Encoded: "cNzq3Q+cehvIu5AeA0icEnO8K600G4aZtXio3Pc28ZA=", options: .ignoreUnknownCharacters) ?? Data()
            let iv = Data(base64Encoded: "Qu7Rgqns4iaUzyVKW/Xr7g==", options: .ignoreUnknownCharacters) ?? Data()
            let aes = try Encryption(key: key, iv: iv)
            let decryptedData = try aes.decrypt(sourceData)
            
            return decryptedData.base64EncodedString().fromBase64()
        } catch {
            print("Failed")
            return nil
        }
    }
    
    static private func decryptGoogleAppID() -> String? {
        do {
            let sourceData = Data(base64Encoded: "saybe0l6jSHU7EV0aOYif95/mcV6xfggbhsgxXPZLZEowfotWd6YR/fRDEJ1idxE", options: .ignoreUnknownCharacters) ?? Data()
            let key = Data(base64Encoded: "l5j9Kx+DECsahjvWTC7289GYXuxjbkyBEFcMRxVxZys=", options: .ignoreUnknownCharacters) ?? Data()
            let iv = Data(base64Encoded: "kP0UGjG8DIFaQ2cPajg0/w==", options: .ignoreUnknownCharacters) ?? Data()
            let aes = try Encryption(key: key, iv: iv)
            let decryptedData = try aes.decrypt(sourceData)
            
            return decryptedData.base64EncodedString().fromBase64()
        } catch {
            print("Failed")
            return nil
        }
    }
    
    static private func decryptSenderID() -> String? {
        do {
            let sourceData = Data(base64Encoded: "S5JePOTRq1QeeXF8pwd4ew==", options: .ignoreUnknownCharacters) ?? Data()
            let key = Data(base64Encoded: "1SXT5EbmJVOPt7k4l5yuwMAo/vTsIhISyoL7cxFEQaI=", options: .ignoreUnknownCharacters) ?? Data()
            let iv = Data(base64Encoded: "9vdTAJX10IISvgIu5eWcoQ==", options: .ignoreUnknownCharacters) ?? Data()
            let aes = try Encryption(key: key, iv: iv)
            let decryptedData = try aes.decrypt(sourceData)
            
            return decryptedData.base64EncodedString().fromBase64()
        } catch {
            print("Failed")
            return nil
        }
    }
    
    static private func path(_ keys: String...) -> String {
        var current = Bundle.main.infoDictionary
        for (index, key) in keys.enumerated() {
            if index == keys.count - 1 {
                guard let
                        result = (current?[key] as? String)?.replacingOccurrences(of: "\\", with: ""),
                      !result.isEmpty else {
                    assertionFailure(keys.joined(separator: " -> ").appending(" not found"))
                    return ""
                }
                return result
            }
            current = current?[key] as? [String: Any]
        }
        assertionFailure(keys.joined(separator: " -> ").appending(" not found"))
        return ""
    }
}
