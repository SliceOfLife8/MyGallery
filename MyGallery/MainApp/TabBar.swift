//
//  TabBar.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import UIKit

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
            createNavController(for: HomeVC(), title: "Home", image: UIImage(systemName: "house")),
            createNavController(for: GalleryVC(), title: "Gallery", image: UIImage(systemName: "photo.on.rectangle")),
            createNavController(for: SearchImagesVC(), title: "Search", image: UIImage(systemName: "magnifyingglass"))
        ]
    }
    
}
