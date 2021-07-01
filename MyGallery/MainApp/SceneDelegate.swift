//
//  SceneDelegate.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import UIKit

enum UserDefaultsKeys: String {
    case TabBarIndex
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow? {
        didSet {
            window?.overrideUserInterfaceStyle = UserDefaults.standard.overridedUserInterfaceStyle
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: UIScreen.main.bounds)
        let home = TabBar()
        self.window?.rootViewController = home
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
        let quickActionDetected: Bool = checkForQuickActions(connectionOptions.shortcutItem)
        if quickActionDetected { return }
        home.selectedIndex = retrieveTabBarIndexState()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        storeTabBarIndexState()
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        // Starts monitoring network reachability status changes
        ReachabilityManager.shared.startMonitoring()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        // Stops monitoring network reachability status changes
        ReachabilityManager.shared.stopMonitoring()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        storeTabBarIndexState()
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if let shortcutType = TabBarValues(rawValue: shortcutItem.type), let tabBar = self.window?.rootViewController as? TabBar {
            tabBar.selectedIndex = shortcutType.index
        }
    }
    
    /// #Store selectedIndex (exclude search case)
    private func storeTabBarIndexState() {
        if let tabBar = self.window?.rootViewController as? TabBar{
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.TabBarIndex.rawValue)
            let index = (tabBar.selectedIndex == 1) ? 0 : tabBar.selectedIndex
            UserDefaults.standard.setValue(index, forKey: UserDefaultsKeys.TabBarIndex.rawValue)
        }
    }
    
    private func retrieveTabBarIndexState() -> Int {
        let index = UserDefaults.standard.integer(forKey: UserDefaultsKeys.TabBarIndex.rawValue)
        return index
    }
    
    /*
     Scenario 1. The App Hasn’t Been Loaded.
     If your app hasn’t been loaded before tapping the quick action, the following code within the scene delegate will be used to respond to the tapping. Specifically, the shortcut item (i.e., the quick action) can be accessed as a connection option for the current scene session.
     Scenario 2. The App Has Been Loaded.
     To respond to the tap, we’ll implement the following method within the scene delegate. This method is called when the app has been loaded and the user has just tapped a quick action item.
     */
    private func checkForQuickActions(_ item: UIApplicationShortcutItem?) -> Bool {
        if let shortcutItem = item, let shortcutType = TabBarValues(rawValue: shortcutItem.type), let tabBar = self.window?.rootViewController as? TabBar {
            tabBar.selectedIndex = shortcutType.index
            return true
        } else {
            return false
        }
    }
    
}
