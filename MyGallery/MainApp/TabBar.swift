//
//  TabBar.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import UIKit

internal enum TabBarValues: String {
    case GalleryAction
    case VideosAction
    case SearchAction
    
    var index: Int {
        switch self {
        case .GalleryAction:
            return 0
        case .VideosAction:
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
            createNavController(for: GalleryVC(GalleryViewModel()), title: "Gallery", image: UIImage(systemName: "photo.on.rectangle")),
            createNavController(for: VideosVC(), title: "Videos", image: UIImage(systemName: "video.fill")),
            createNavController(for: SearchImagesVC(SearchViewModel()), title: "Search", image: UIImage(systemName: "magnifyingglass"))
        ]
    }
    
}
