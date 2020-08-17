//
//  Rewards.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-07-24.
//  Copyright © 2017 iList AB. All rights reserved.
//

import Foundation
import DateTools

private let kAPIKeyId = "id"
private let kAPIKeyOrder = "order"
private let kAPIKeyPages = "pages"
private let kAPIKeyBackgrounds = "backgrounds"
private let kAPIKeyTitle = "title"
private let kAPIKeyClaimable = "is_claimable"
private let kAPIKeyShareable = "is_shareable"
private let kAPIKeyConsumeAction = "consume_action"
private let kAPIKeyStartDate = "start_date"
private let kAPIKeyEndDate = "end_date"
private let kAPIKeyNumberOfUses = "number_of_uses"
private let kAPIKeyDisclaimer = "disclaimer"
private let kAPIKeyLongitude = "lng"
private let kAPIKeyLatitude = "lat"
private let kAPIKeyBrand = "brand"
private let kAPIKeyOriginalBrand = "original_brand"
private let kAPIKeyReceivedFrom = "received_from"
private let kAPIKeyCreated = "created"
private let kAPIKeyUpdated = "updated"

open class Reward {
    
    var id: Int = 0
    var order: Int = 0
    var brand: Int = 0
    var originalBrand: Int?
    var receivedFrom: Int?
    
    var title: String = ""
    var pages: [RewardPage]
    var sharedContent = false
    
    var claimable: Bool = false
    var shareable: Bool = false
    var consumeAction: ConsumeAction?
    var numberOfUses: Int = 0
    
    var disclaimer: String?
    
    var startDate: Date?
    var endDate: Date?
    
    var created: Date?
    var updated: Date?
    
    var longitude: Double?
    var latitude: Double?
    
    var iconUrl: String?
    var identity: String?
    
    init(dictionary: [String:Any]) {
        print("huy")
        if let iconUrl = dictionary["icon_url"] as? String {
            self.iconUrl = iconUrl
        }
        if let identity = dictionary["identity"] as? String {
            self.identity = identity
        }
        if let id = dictionary[kAPIKeyId] as? Int {
            self.id = id
        }
        if let order = dictionary[kAPIKeyOrder] as? Int {
            self.order = order
        }
        if let brand = dictionary[kAPIKeyBrand] as? Int {
            self.brand = brand
        }
        if let originalBrand = dictionary[kAPIKeyOriginalBrand] as? Int {
            self.originalBrand = originalBrand
        }
        if let receivedFrom = dictionary[kAPIKeyReceivedFrom] as? Int {
            self.receivedFrom = receivedFrom
        }
        if let title = dictionary[kAPIKeyTitle] as? String {
            self.title = title
        }
        if let pages = dictionary[kAPIKeyPages] as? Array<[String:Any]> {
            let pages = pages.map({ RewardPage(dictionary: $0) }).sorted(by: { $0.order < $1.order })
            self.pages = pages
        } else {
            pages = []
        }
        if let claimable = dictionary[kAPIKeyClaimable] as? Bool {
            self.claimable = claimable
        }
        if let shareable = dictionary[kAPIKeyShareable] as? Bool {
            self.shareable = shareable
        }
        if let consumeAction = dictionary[kAPIKeyConsumeAction] as? Int {
            self.consumeAction = ConsumeAction(rawValue: consumeAction)!
        }
        
        if let sharedContent = dictionary["shread_content"] as? Bool {
            self.sharedContent = sharedContent
        }
        
        if let numberOfUses = dictionary[kAPIKeyNumberOfUses] as? Int {
            self.numberOfUses = numberOfUses
        }
        if let disclaimer = dictionary[kAPIKeyDisclaimer] as? String {
            self.disclaimer = disclaimer
        }
        if let longitude = dictionary[kAPIKeyLongitude] as? Double {
            self.longitude = longitude
        }
        if let latitude = dictionary[kAPIKeyLatitude] as? Double {
            self.latitude = latitude
        }
        
        
        if let startDateString = dictionary[kAPIKeyStartDate] as? String, let date = NSDate(string: startDateString, formatString: APIDefinitions.FullDateFormat) {
            startDate = date as Date
        }
        if let endDateString = dictionary[kAPIKeyEndDate] as? String, let date = NSDate(string: endDateString, formatString: APIDefinitions.FullDateFormat) {
            endDate = date as Date
        }
        if let createdString = dictionary[kAPIKeyCreated] as? String, let createdDate = NSDate(string: createdString, formatString: APIDefinitions.FullDateFormat) {
            created = createdDate as Date
        }
        if let updatedString = dictionary[kAPIKeyUpdated] as? String, let updatedDate = NSDate(string: updatedString, formatString: APIDefinitions.FullDateFormat) {
            updated = updatedDate as Date
        }
    }
    
}
