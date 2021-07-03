//
//  Ext_UIApplication.swift
//  MyGallery
//
//  Created by Christos Petimezas on 26/6/21.
//

import UIKit

extension UIApplication {
    
    var sceneDelegate: SceneDelegate {
        get {
            return self.connectedScenes
                .first!.delegate as! SceneDelegate
        }
    }
    
    func override(_ userInterfaceStyle: UIUserInterfaceStyle) {
        if supportsMultipleScenes {
            for connectedScene in connectedScenes {
                if let scene = connectedScene as? UIWindowScene {
                    for window in scene.windows {
                        window.overrideUserInterfaceStyle = userInterfaceStyle
                    }
                }
            }
        }
        else {
            for window in windows {
                window.overrideUserInterfaceStyle = userInterfaceStyle
            }
        }
    }
    
    static var topSafeAreaHeight: CGFloat {
        var topSafeAreaHeight: CGFloat = 0
        let window = UIApplication.shared.windows[0]
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        topSafeAreaHeight = safeFrame.minY
        return topSafeAreaHeight
    }
    
    class func topViewController(base: UIViewController? = UIApplication.shared.windows[0].rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
    
    /// #Delete Loaf VC otherwise we have issue when we are trying to show a UIContextMenu due to fact that menu is presented also.
    class func deleteLoafView() {
        guard let topVC = topViewController()?.classForCoder else { return }
        if NSStringFromClass(topVC) == "Loaf.LoafViewController" {
            UIApplication.shared.windows[0].rootViewController?.presentedViewController?.dismiss(animated: false)
        }
    }
    
    class func editAlbumAsCurrentVC() -> Bool {
        return (UIApplication.shared.windows[0].rootViewController?.children.last as? UINavigationController)?.viewControllers.last is EditCustomAlbumVC
    }
}
