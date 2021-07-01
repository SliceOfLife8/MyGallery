//
//  BaseVC.swift
//  MyGallery
//
//  Created by Christos Petimezas on 1/7/21.
//

import Foundation
import Reachability
import Loaf

class BaseVC: UIViewController {
    
    private var connectionStatusUnvailable: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
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

extension Equatable {
    func oneOf(other: Self...) -> Bool {
        return other.contains(self)
    }
}
