//
//  BaseVC.swift
//  MyGallery
//
//  Created by Christos Petimezas on 1/7/21.
//

import Foundation
import Reachability
import Loaf
import FirebaseCrashlytics
import FirebaseAnalytics

class BaseVC: UIViewController {
    
    private var connectionStatusUnvailable: Bool = false
    private var deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Not available"
    
    deinit{
        NotificationCenter.default.removeObserver(self)
        print("\(String(describing: type(of: self))) deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// #Setup unique keys for crashlytics reports
        Crashlytics.crashlytics().log("View Controller: \(String(describing: type(of: self)))")
        Crashlytics.crashlytics().setUserID(deviceID)
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChangeNotification), name: .didChangeLanguage, object: nil)
        languageDidChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }

    /// #Detect when darkMode changed
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.view.subviews.forEach { subview in
                if let tv = subview as? UITableView {
                    tv.reloadData()
                } else if let cv = subview as? UICollectionView {
                    cv.reloadData()
                }
            }
        }
    }
    
    /// #Send Firebase analytics when an api connection occured
    func sendAnalytics(_ event: String = "api_call") {
        let currentVC = String(describing: type(of: self)) as NSString
        FirebaseAnalytics.Analytics.logEvent(event, parameters: [
            AnalyticsParameterScreenClass: currentVC,
            "user_device_id" : deviceID
        ])
    }
    
    @objc func languageDidChangeNotification(notification: Notification) {
        languageDidChange()
    }
    
    /// #Override this method in order to receive language real-time changes.
    func languageDidChange(){}

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        self.vibrateIfEnabled()
    }

    func vibrateIfEnabled() {
        let visibleVC = UIApplication.topViewController()
        if Settings.shared.retrieveState(forKey: .vibration) && (visibleVC is LanguageSelectionVC || visibleVC is DarkModeSelectionVC || visibleVC is ThemeSelectionVC || visibleVC is SoundSettingsVC || visibleVC is UIAlertController) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
}

extension BaseVC: NetworkStatusListener {
    func networkStatusDidChange(status: Reachability.Connection) {
        if status == .unavailable && !connectionStatusUnvailable {
            connectionStatusUnvailable = true
            Loaf("network_fail".localized(), state: .custom(.init(backgroundColor: UIColor(named: "Red")!, icon: Loaf.Icon.error, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
            self.playMusicIfEnabled(.error)
        } else if connectionStatusUnvailable && status.oneOf(other: .wifi, .cellular) {
            connectionStatusUnvailable = false
            Loaf("network_is_back".localized(), state: .custom(.init(backgroundColor: UIColor(hexString: "#2ecc71"), icon: Loaf.Icon.success, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
            self.playMusicIfEnabled(.message)
        }
    }
}
