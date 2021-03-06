//
//  Ext_NotificationName.swift
//  MyGallery
//
//  Created by Christos Petimezas on 7/7/21.
//

import Foundation

extension Notification.Name {
    static let didChangeLanguage = Notification.Name("didChangeLanguage")
    static let didAlbumCreated = Notification.Name("didAlbumCreated")
    static let didGalleryBGImageChanged = Notification.Name("didGalleryBackgroundImageChanged")
    static let fcmToken = Notification.Name("FCMToken")
}
