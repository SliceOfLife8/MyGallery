//
//  TabBar.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import UIKit

/* TODO: Last steps for production:
 1) Add localization & add item to settings for user to change language.
 2) Change appIcon
 3) Add Unit & UI Tests
 4) Add Firebase Crashlytics
 5) Edit album bug with Loaf view when UIMenu opens at the same time
 */

internal enum TabBarValues: String {
    case GalleryAction
    case SearchAction
    case SettingsAction
    
    var index: Int {
        switch self {
        case .GalleryAction:
            return 0
        case .SearchAction:
            return 1
        case .SettingsAction:
            return 2
        }
    }
}

class TabBar: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        //UITabBar.appearance().barTintColor = .systemBackground
        tabBar.tintColor = .label
        setupVCs()
    }
    
    fileprivate func createNavController(for rootViewController: UIViewController,
                                         title: String,
                                         image: UIImage?) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }
    
    func setupVCs() {
        viewControllers = [
            createNavController(for: GalleryVC(GalleryViewModel()), title: "Gallery", image: UIImage(systemName: "photo.on.rectangle")),
            createNavController(for: SearchImagesVC(SearchViewModel()), title: "Search", image: UIImage(systemName: "magnifyingglass")),
            createNavController(for: SettingsVC(), title: "Settings", image: UIImage(systemName: "gear")),
        ]
    }
    
}
