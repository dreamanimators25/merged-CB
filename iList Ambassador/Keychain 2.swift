//
//  Keychain.swift
//  iList Ambassador
//
//  Created by External Three. Consultant on 18/11/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Locksmith

class Keychain {

    // Note: this is because of a previously used depencency called Heimdallr for handling OAuth.
    private static let userAccount = "ilist_account"
    private static let keychainService = "de.rheinfabrik.heimdallr.oauth"
    private static let accessTokenKey = "access_token"
    private static let refreshTokenKey = "refresh_token"

    static func storeAccessToken(_ accessToken: String, refreshToken: String) {
        do {
            let data = [accessTokenKey : accessToken, refreshTokenKey : refreshToken]
            try Locksmith.updateData(data: data, forUserAccount: userAccount, inService: keychainService)
        } catch {
            print("error trying to store access token: \(error.localizedDescription)")
        }
    }

    static var hasAccessToken: Bool {
        let keychain = Locksmith.loadDataForUserAccount(userAccount: userAccount, inService: keychainService)
        return keychain?[accessTokenKey] != nil
    }

    static func loadAccessToken() -> String? {
        let keychain = Locksmith.loadDataForUserAccount(userAccount: userAccount, inService: keychainService)
        return keychain?[accessTokenKey] as? String
    }

    static func loadRefreshToken() -> String? {
        let keychain = Locksmith.loadDataForUserAccount(userAccount: userAccount, inService: keychainService)
        return keychain?[refreshTokenKey] as? String
    }

    static func clearAccessToken() {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: userAccount, inService: keychainService)
        } catch {
            print("error trying to delete access token: \(error.localizedDescription)")
        }
    }

    
}
