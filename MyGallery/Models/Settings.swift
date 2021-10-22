//
//  Settings.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 22/10/21.
//

import UIKit

struct Section {
    let title: String?
    let bottomTitle: String?
    var options: [SettingsOption]
}

struct SettingsOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor?
    var accessoryType: UITableViewCell.AccessoryType
    let handle: (() -> Void)
}
