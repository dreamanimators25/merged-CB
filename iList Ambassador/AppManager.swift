//
//  AppManager.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 30/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation

private let kNumberOfSessionsKey = "numberOfSessionsKey"

class AppManager {
    
    // MARK: - Sessions
    
    class func incrementNumberOfSessions() {
        let defaults = UserDefaults.standard
        var numSessions: Int = defaults.integer(forKey: kNumberOfSessionsKey)
        numSessions = numSessions + 1
        defaults.set(numSessions, forKey: kNumberOfSessionsKey)
        defaults.synchronize()
    }
    
    class func numberOfSessions() -> Int {
        return UserDefaults.standard.integer(forKey: kNumberOfSessionsKey)
    }
    
    // MARK: - Tutorial
    
    class func setAccessToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "ACCESS_TOKEN")
        UserDefaults.standard.synchronize()
    }
    
    class func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: "ACCESS_TOKEN")
    }
    
    class func setRefreshToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "REFRESH_TOKEN")
        UserDefaults.standard.synchronize()
    }
    
    class func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: "REFRESH_TOKEN")
    }
    
    class func setFirstRun() {
        UserDefaults.standard.set("1ST_RUN", forKey: "1ST_RUN_KEY")
        UserDefaults.standard.synchronize()
    }
    
    class func isFirstRun() -> Bool {
        guard let firstRunStr = UserDefaults.standard.string(forKey: "1ST_RUN_KEY") else { return true }
        return firstRunStr.isEmpty
    }
    
    class func hasPresentedTutorial() -> Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: "hasPresentedProfileTutorial")
    }
    
    class func setHasPresentedTutorial() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "hasPresentedProfileTutorial")
    }
    
    // MARK: - Introduction movie
    
    class func hasPresentedIntroductionSlides() -> Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: "hasPresentedIntroductionSlides")
    }
    
    class func setHasPresentedIntroductionSlides() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "hasPresentedIntroductionSlides")
    }
    
}
