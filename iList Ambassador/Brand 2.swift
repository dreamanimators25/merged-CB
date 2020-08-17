//
//  Brand.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 06/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation

private let kAPIKeyId = "id"
private let kAPIKeyName = "name"
private let kAPIKeyDescription = "description"
private let kAPIKeyWebsite = "website"
private let kAPIKeyLogotype = "logotype"
private let kAPIKeyDisclaimer = "disclaimer"
private let kAPIKeyLongitude = "lng"
private let kAPIKeyLatitude = "lat"


open class Brand {
    
    var id: Int = 0
    var name: String = ""
    var description: String = ""
    var website: String?
    var logotypeUrl: String = "" // TODO: Set as optional without initiation
    
    var disclaimer: String?
    
    var longitude: Double?
    var latitude: Double?
    
    var isPublic = false
    var code = ""
    
    init(dictionary: [String:Any]) {
        if let id = dictionary[kAPIKeyId] as? Int {
            self.id = id
        }
        if let name = dictionary[kAPIKeyName] as? String {
            self.name = name
        }
        if let code = dictionary["code"] as? String {
            self.code = code
        }

        if let publ = dictionary["public"] as? Bool {
            self.isPublic = publ
        }
        if let description = dictionary[kAPIKeyDescription] as? String {
            self.description = description
        }
        if let website = dictionary[kAPIKeyWebsite] as? String {
            self.website = website
        }
        if let logotypeUrl = dictionary[kAPIKeyLogotype] as? String {
            self.logotypeUrl = logotypeUrl
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
    }

    class func randomBrands() -> [Brand] {
        let brand1 = Brand(dictionary: [String:Any]())
        brand1.id = 1
        brand1.name = "iList"
        brand1.logotypeUrl = "https://scontent-ams3-1.xx.fbcdn.net/hprofile-xpt1/v/t1.0-1/p160x160/11219536_1393328527662764_2638008287924673771_n.jpg?oh=03874515bcfe2c9f9d63bc9ccd9976bf&oe=57554B5E"
        
        let brand2 = Brand(dictionary: [String:Any]())
        brand2.id = 2
        brand2.name = "IKEA"
        brand2.logotypeUrl = "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcS5UtrpV-HUVaQ3f1MEqJsKuDKJj1WJ-c2apfaDQ-gJPhFV_g7S"
        
        let brand3 = Brand(dictionary: [String:Any]())
        brand3.id = 3
        brand3.name = "App Shack"
        brand3.logotypeUrl = "https://scontent-ams3-1.xx.fbcdn.net/hphotos-frc1/t31.0-8/10003688_733833816661056_2104911175_o.jpg"
        
        return [brand1, brand2, brand3]
    }
    
}
