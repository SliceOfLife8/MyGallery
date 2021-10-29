//
//  TabBar.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import UIKit

internal enum TabBarValues: String {
    case SearchAction
    case AlbumAction
    
    var index: Int {
        return (self == .SearchAction) ? 1 : 2
    }
}

class TabBar: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tabBar.tintColor = .label
        setupVCs()
    }
    
    fileprivate func createNavController(for rootViewController: UIViewController,
                                         title: String,
                                         image: UIImage?) -> UIViewController {
        let navController = MyNavigationController(rootViewController: rootViewController)
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

class MyNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}
