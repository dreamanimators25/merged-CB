//
//  AmbassadorshipContent.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 21/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation

private let kAPIKeyId = "id"
private let kAPIKeyContent = "content"
private let kAPIKeyUsed = "used"
private let kAPIKeyAmbassadorship = "ambassadorship"
private let kAPIKeyReceivedFrom = "received_from"
private let kAPIKeyCreated = "created"
private let kAPIKeyUpdated = "updated"

open class AmbassadorshipContent {
    
    var id: Int = 0
    var ambassadorship: Int = 0
    var content: Content
    
    var used: Bool = false
    var receivedFrom: Int?
    
    var created: Date?
    var updated: Date?
    
    init(dictionary: [String:Any]) {
        if let id = dictionary[kAPIKeyId] as? Int {
            self.id = id
        }
        if let ambassadorship = dictionary[kAPIKeyAmbassadorship] as? Int {
            self.ambassadorship = ambassadorship
        }
        
        content = Content(dictionary: dictionary[kAPIKeyContent] as! [String:Any])
        
        if let used = dictionary[kAPIKeyUsed] as? Bool {
            self.used = used
        }
        if let receivedFrom = dictionary[kAPIKeyReceivedFrom] as? Int {
            self.receivedFrom = receivedFrom
        }
        if let createdString = dictionary[kAPIKeyCreated] as? String, let createdDate = NSDate(string: createdString, formatString: APIDefinitions.FullDateFormat) {
            created = createdDate as Date
        }
        if let updatedString = dictionary[kAPIKeyUpdated] as? String, let updatedDate = NSDate(string: updatedString, formatString: APIDefinitions.FullDateFormat) {
            updated = updatedDate as Date
        }
    }
    
}
