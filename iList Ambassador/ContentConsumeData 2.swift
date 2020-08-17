//
//  ContentConsumeData.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-08-11.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation

private let kAPIKeyId = "id"
private let kAPIKeyConsumeData = "identity"
private let kAPIKeyType = "type"
private let kAPIKeyShowAsQr = "show_as_qr"
private let kAPIKeyUsedAt = "used_at"
private let kAPIKeyContent = "content"
private let kAPIKeyCreated = "created"
private let kAPIKeyUpdated = "updated"

struct ContentConsumeData {
    var id: Int = 0
    var content: Int = 0
    var consumeData: String?
    var type: ContentConsumeDataType
    
    var showAsQr: Bool = false
    var usedAt: Date?
    
    var created: Date?
    var updated: Date?
    
    init(dictionary: [String:Any]) {
        if let id = dictionary[kAPIKeyId] as? Int {
            self.id = id
        }
        if let content = dictionary[kAPIKeyContent] as? Int {
            self.content = content
        }
        if let consumeData = dictionary[kAPIKeyConsumeData] as? String {
            self.consumeData = consumeData
        }
        if let typeInt = dictionary[kAPIKeyType] as? Int, let type = ContentConsumeDataType(rawValue: typeInt) {
            self.type = type
        } else {
            self.type = .other
        }
        if let showAsQr = dictionary[kAPIKeyShowAsQr] as? Bool {
            self.showAsQr = showAsQr
        }
        if let usedAtString = dictionary[kAPIKeyUsedAt] as? String, let usedAtDate = NSDate(string: usedAtString, formatString: APIDefinitions.FullDateFormat) {
            usedAt = usedAtDate as Date
        }
        if let createdString = dictionary[kAPIKeyCreated] as? String, let createdDate = NSDate(string: createdString, formatString: APIDefinitions.FullDateFormat) {
            created = createdDate as Date
        }
        if let updatedString = dictionary[kAPIKeyUpdated] as? String, let updatedDate = NSDate(string: updatedString, formatString: APIDefinitions.FullDateFormat) {
            updated = updatedDate as Date
        }
    }
}
