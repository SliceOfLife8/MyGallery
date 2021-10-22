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
    
    /// #Send Firebase analytics when an api connection occured
    func sendAnalytics() {
        let currentVC = String(describing: type(of: self)) as NSString
        FirebaseAnalytics.Analytics.logEvent("api_call", parameters: [
            AnalyticsParameterScreenClass: currentVC,
            "user_device_id" : deviceID
        ])
    }
    
    @objc func languageDidChangeNotification(notification: Notification) {
        languageDidChange()
    }
    
    /// #Override this method in order to receive language real-time changes.
    func languageDidChange(){}
    
}

extension BaseVC: NetworkStatusListener {
    func networkStatusDidChange(status: Reachability.Connection) {
        if status == .unavailable && !connectionStatusUnvailable {
            connectionStatusUnvailable = true
            Loaf("network_fail".localized(), state: .custom(.init(backgroundColor: UIColor(named: "RedColor")!, icon: Loaf.Icon.error, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
        } else if connectionStatusUnvailable && status.oneOf(other: .wifi, .cellular) {
            connectionStatusUnvailable = false
            Loaf("network_is_back".localized(), state: .custom(.init(backgroundColor: UIColor(hexString: "#2ecc71"), icon: Loaf.Icon.success, textAlignment: .center, iconAlignment: .right)), location: .top, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.short)
        }
    }
}
