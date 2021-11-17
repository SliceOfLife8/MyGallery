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

    private var bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.4, 0.9, 1.02, 1.0]
        bounceAnimation.duration = TimeInterval(0.3)
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        return bounceAnimation
    }()

    
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

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let currentIndex = tabBar.items?.firstIndex(of: item)
        makeEffect(tabBar, currentIndex: currentIndex ?? 0)
        let selectedVC = (self.selectedViewController as? UINavigationController)?.viewControllers.first
        /// User has already select index
        if selectedIndex == 0 && currentIndex == 0 {
            let galleryVC =  selectedVC as? GalleryVC
            galleryVC?.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        } else if selectedIndex == 1 && currentIndex == 1 {
            let searchImagesVC = selectedVC as? SearchImagesVC
            searchImagesVC?.searchTF.becomeFirstResponder()
        }
    }

    private func makeEffect(_ tabBar: UITabBar, currentIndex: Int) {
        guard let imageView = (tabBar.subviews[safe: currentIndex + 1]?.subviews.first as? UIVisualEffectView)?.contentView.subviews.filter({ $0 is UIImageView }).first else {
            return
        }
        imageView.layer.add(bounceAnimation, forKey: nil)
        if Settings.shared.retrieveState(forKey: .vibration) {
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        }
    }
    
}

class MyNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}
