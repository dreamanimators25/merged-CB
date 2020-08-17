//
//  ConnectionRequest.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 18/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import DateTools

private let kAPIKeyId = "id"
private let kAPIKeyMessage = "message"
private let kAPIKeyCreated = "created"
private let kAPIKeyViewed = "viewed"
private let kAPIKeyRejected = "rejected"
private let kAPIKeyFromUser = "from_user"
private let kAPIKeyToUser = "to_user"

open class Connection {
    
    var id: Int = 0
    
    var created: Date?
    
    var fromUser: User
    var toUser: User
    
    init() {
        self.id = 123
        self.fromUser = User.init()
        self.toUser = User.init()
    }
    
    init(dictionary: [String:Any]) {
        if let id = dictionary[kAPIKeyId] as? Int {
            self.id = id
        }
        if let created = dictionary[kAPIKeyCreated] as? String {
            self.created = NSDate(string: created, formatString: APIDefinitions.FullDateFormat) as Date?
        }
        let fromUserDict = dictionary[kAPIKeyFromUser] as? [String:Any]
        self.fromUser = User(dictionary: fromUserDict!)
        let toUserDict = dictionary[kAPIKeyToUser] as? [String:Any]
        self.toUser = User(dictionary: toUserDict!)
    }
    
    func toDictionary() -> [String:Any] {
        var dict: [String: AnyObject] = [:]
        
        dict[kAPIKeyId] = id as AnyObject?
        if let created = created {
            dict[kAPIKeyCreated] = (created as NSDate).formattedDate(withFormat: APIDefinitions.FullDateFormat) as AnyObject?
        }
        dict[kAPIKeyFromUser] = fromUser
        dict[kAPIKeyToUser] = toUser
        
        return dict
    }
    
}

open class ConnectionRequest {
    
    var id: Int = 0
    var message: String = ""
    
    var created: Date?
    var viewed: Date?
    var rejected: Date?
    
    var fromUser: User
    var toUser: User
    
    var requestRejected: Bool {
        get {
            return rejected != nil
        }
    }
    
    init() {
         self.id = 123
        self.message = "asdasd"
        self.fromUser = User.init()
        self.viewed = nil
        self.toUser = User.init()
    }
    
    init(dictionary: [String:Any]) {
        if let id = dictionary[kAPIKeyId] as? Int {
            self.id = id
        }
        if let message = dictionary[kAPIKeyMessage] as? String {
            self.message = message
        }
        if let created = dictionary[kAPIKeyCreated] as? String {
            self.created = NSDate(string: created, formatString: APIDefinitions.FullDateFormat) as Date?
        }
        if let viewed = dictionary[kAPIKeyViewed] as? String {
            self.viewed = NSDate(string: viewed, formatString: APIDefinitions.FullDateFormat) as Date?
        }
        if let rejected = dictionary[kAPIKeyRejected] as? String {
            self.rejected = NSDate(string: rejected, formatString: APIDefinitions.FullDateFormat) as Date?
        }
        let fromUserDict = dictionary[kAPIKeyFromUser] as! [String:Any]
        self.fromUser = User(dictionary: fromUserDict)
        let toUserDict = dictionary[kAPIKeyToUser] as! [String:Any]
        self.toUser = User(dictionary: toUserDict)
    }
    
    func toDictionary() -> [String:Any] {
        var dict: [String: AnyObject] = [:]
        
        dict[kAPIKeyId] = id as AnyObject?
        dict[kAPIKeyMessage] = message as AnyObject?

        if let created = created {
            dict[kAPIKeyCreated] = (created as NSDate).formattedDate(withFormat: APIDefinitions.FullDateFormat) as AnyObject?
        }
        if let viewed = viewed {
            dict[kAPIKeyViewed] = (viewed as NSDate).formattedDate(withFormat: APIDefinitions.FullDateFormat) as AnyObject?
        }
        if let rejected = rejected {
            dict[kAPIKeyRejected] = (rejected as NSDate).formattedDate(withFormat: APIDefinitions.FullDateFormat) as AnyObject?
        }
        
        dict[kAPIKeyFromUser] = fromUser
        dict[kAPIKeyToUser] = toUser
        
        return dict
    }
    
}
