//
//  TabBar.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import UIKit

internal enum TabBarValues: String {
    case HomeAction
    case GalleryAction
    case SearchAction
    
    var index: Int {
        switch self {
        case .HomeAction:
            return 0
        case .GalleryAction:
            return 1
        case .SearchAction:
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
            createNavController(for: HomeVC(HomeViewModel()), title: "Home", image: UIImage(systemName: "house")),
            createNavController(for: GalleryVC(), title: "Gallery", image: UIImage(systemName: "photo.on.rectangle")),
            createNavController(for: SearchImagesVC(SearchViewModel()), title: "Search", image: UIImage(systemName: "magnifyingglass"))
        ]
    }
    
}
