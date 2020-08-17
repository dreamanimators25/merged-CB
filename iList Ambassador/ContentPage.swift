//
//  ContentPage.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 21/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
    
private let kAPIKeyId = "id"
private let kAPIKeyBackgrounds = "backgrounds"
private let kAPIKeyComponents = "components"
private let kAPIKeyOrder = "order"
private let kAPIKeyContent = "content"
private let kAPIKeyCreated = "created"
private let kAPIKeyUpdated = "updated"
private let kAPIKeyIdentity = "identity"

open class ContentPage {
    
    var id: Int = 0
    var backgrounds: ContentPageBackground?
    var multiLinkBackgrounds = [ContentPageBackground]()
    var components: [ContentPageComponent]
    //var backgrounds: [Backgrounds]?
    
    var consumeActionComponent: ConsumeActionComponents?
    
    var frameUrl : String?  //Sameer 25/4/2020
    
    var order: Int = 0
    var content: Int = 0
    
    var created: Date?
    var updated: Date?
    var identity: String?
    var consumeAction = -1
    
    var is_shareable: Bool?
    var isBodyShare: Bool?
    
    var unlim: Bool?

    init(dictionary: [String:Any]) {
        print("diccccc = \(dictionary)")
        
        if let unlim = dictionary["unlimited_uses"] as? Bool {
            self.unlim = unlim
        }
        
        if let bodyShare = dictionary["body_is_shareable"] as? Bool {
            self.isBodyShare = bodyShare
        }
        
        if let identity = dictionary[kAPIKeyIdentity] as? String {
            self.identity = identity
            print("sks = \(self.identity)")
        }
        if let id = dictionary[kAPIKeyId] as? Int {
            self.id = id
        }
        
        if let frameURL = dictionary["frame_url"] as? String {
            self.frameUrl = frameURL
        }
        
        if let shareable = dictionary["is_shareable"] as? Bool {
            self.is_shareable = shareable
        }
        if let consume = dictionary["consume_action"] as? Int {
            self.consumeAction = consume
        }
        
        //Sameer 11/6/2020
        if let consumeActComp = dictionary["consume_action_component"] as? [String:Any] {
            self.consumeActionComponent = ConsumeActionComponents.init(dictionary: consumeActComp)
        }
        
        if self.consumeAction == 9 {
            if let backgroundsArray = dictionary[kAPIKeyBackgrounds] as? Array<[String:Any]> {
                
                /*
                if let background = backgroundsArray.first {
                    print("dicccc = \(background)")
                    self.backgrounds = ContentPageBackground(dictionary: background)
                }*/ //old Devs
                
                
                for back in backgroundsArray {
                    self.multiLinkBackgrounds.append(ContentPageBackground(dictionary: back))
                }
                
                
                if let background = backgroundsArray.first(where: { $0["order"] as! Int == 0 }) {
                    self.backgrounds = ContentPageBackground(dictionary: background)
                }
                
            }
        }else {
            if let backgroundsArray = dictionary[kAPIKeyBackgrounds] as? Array<[String:Any]> {
                if let background = backgroundsArray.first(where: { $0["order"] as! Int == 0 }) {
                    self.backgrounds = ContentPageBackground(dictionary: background)
                }
            }
        }
       
 
        
        /*
        if let backgrounds = dictionary["backgrounds"] as? Array<[String:Any]> {
            self.backgrounds = backgrounds.map({ Backgrounds(dictionary: $0) }).sorted(by: { $0.order! < $1.order! })
        } else {
            self.backgrounds = []
        }
        */
        
        if let componentsArray = dictionary[kAPIKeyComponents] as? Array<[String:Any]> {
            let comp = self.identity
            self.components = componentsArray.map({ ContentPageComponent(dictionary: $0, identity: comp) }).sorted(by: { $0.order < $1.order })
        } else {
            self.components = []
        }
        if let order = dictionary[kAPIKeyOrder] as? Int {
            self.order = order
        }
        if let content = dictionary[kAPIKeyContent] as? Int {
            self.content = content
        }
        if let createdString = dictionary[kAPIKeyCreated] as? String, let createdDate = NSDate(string: createdString, formatString: APIDefinitions.FullDateFormat) {
            created = createdDate as Date
        }
        if let updatedString = dictionary[kAPIKeyUpdated] as? String, let updatedDate = NSDate(string: updatedString, formatString: APIDefinitions.FullDateFormat) {
            updated = updatedDate as Date
        }
    }
    
}
