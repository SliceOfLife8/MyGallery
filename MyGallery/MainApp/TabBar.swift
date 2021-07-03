//
//  TabBar.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import UIKit

/* TODO: Last steps for production:
 1) Add Unit & UI Tests
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
            createNavController(for: GalleryVC(GalleryViewModel()), title: "gallery".localized(), image: UIImage(systemName: "photo.on.rectangle")),
            createNavController(for: SearchImagesVC(SearchViewModel()), title: "search".localized(), image: UIImage(systemName: "magnifyingglass")),
            createNavController(for: SettingsVC(), title: "settings".localized(), image: UIImage(systemName: "gear")),
        ]
    }
    
}
