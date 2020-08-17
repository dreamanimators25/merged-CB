//
//  iListOAuthClientCredentials.swift
//  iList Ambassador
//
//  Created by External Three. Consultant on 16/11/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation

struct iListOAuthClientCredentials {
    
    var clientId: String
    var clientSecret: String
    
    private static let authorizationDict = (Bundle.main.object(forInfoDictionaryKey: "iListAPI") as! NSDictionary)["Authorization"] as! NSDictionary
    
    init() {
        clientId = iListOAuthClientCredentials.getClientId()
        clientSecret = iListOAuthClientCredentials.getClientSecret()
    }
    
    static func getClientId() -> String {
        return authorizationDict["ClientId"] as! String
    }
    
    static func getClientSecret() -> String {
        return authorizationDict["ClientSecret"] as! String
    }
    
}
