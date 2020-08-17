//
//  Activity.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 02/05/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation

private let kAPIKeyData = "data"
private let kAPIKeyVerb = "verb"
private let kAPIKeyActor = "actor"
private let kAPIKeyActorId = "actor_id"
private let kAPIKeyTargetId = "target_id"
private let kAPIKeyTimestamp = "timestamp"
private let kAPIKeyType = "target_content_type"

enum ActivityType: String {
    case user
}

class Activity {
    
//    "target" : "pontus.andersson@appshack.se",
//    "actor" : "simonberglund6d@hotmail.com",
//    "public" : true,
//    "data" : {
//      "format" : "hide_target",
//      "actor_id" : 572,
//      "target_id" : 2
//    },
//    "target_content_type" : "user",
//    "action_object_content_type" : null,
//    "actor_content_type" : "user",
//    "description" : null,
//    "timestamp" : "2016-10-09 18:45:36+0000",
//    "verb" : "sent a friend request to you,"
    
    var verb: String?
    var actor: String?
    var actorId: Int?
    var targetId: Int?
    var timestamp: Date?
    var type: ActivityType?
    
    init(dictionary: [String:Any]) {
        self.verb = dictionary[kAPIKeyVerb] as? String
        self.actor = dictionary[kAPIKeyActor] as? String
        if let timestamp = dictionary[kAPIKeyTimestamp] as? String {
            self.timestamp = NSDate(string: timestamp, formatString: APIDefinitions.FullDateFormat) as Date?
        }
        if let typeString = dictionary[kAPIKeyType] as? String {
            self.type = ActivityType(rawValue: typeString)
        }
        if let dataDict = dictionary[kAPIKeyData] as? [String:Any] {
            self.actorId = dataDict[kAPIKeyActorId] as? Int
            self.targetId = dataDict[kAPIKeyTargetId] as? Int
        }
    }
    
}
