//
//  StoreReviewHelper.swift
//  MyGallery
//
//  Created by Christos Petimezas on 29/6/21.
//

import Foundation
import StoreKit

let defaults = UserDefaults.standard

struct StoreReviewHelper {
    
    static func incrementAppOpenedCount() {
        guard let appOpenCount = defaults.value(forKey: UserDefaults.appOpenedNo) as? Int else {
            defaults.set(1, forKey: UserDefaults.appOpenedNo)
            defaults.set(0, forKey: UserDefaults.reviewRequestNo)
            return
        }
        defaults.set(appOpenCount + 1, forKey: UserDefaults.appOpenedNo)
    }
    
    static func checkAndAskForReview() {
        guard let appOpenCount = defaults.value(forKey: UserDefaults.appOpenedNo) as? Int,
              let reviewRequestCount = defaults.value(forKey: UserDefaults.reviewRequestNo) as? Int else {
            return
        }
        /// By the default setting, it will be called firstly after 10 times (or more) engaging of the user with the app. The next time would be after 20, 60, 240 times and so on.
        let nextlevel = 10 * (StoreReviewHelper.factorial(reviewRequestCount + 1))
        if appOpenCount > nextlevel {
            requestReview()
            defaults.set(reviewRequestCount + 1, forKey: UserDefaults.reviewRequestNo)
            defaults.set(0, forKey: UserDefaults.appOpenedNo)
        }
    }
    
    static func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    static func factorial(_ number: Int) -> Int {
        if number == 0 {
            return 1
        }
        var sum: Int = 1
        for index in 1...number {
            sum *= index
        }
        return sum
    }
}

extension UserDefaults {
    static let appOpenedNo = "app_openned"
    static let reviewRequestNo = "review_requested"
}
