//
//  Backgrounds.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-08-23.
//  Copyright © 2017 iList AB. All rights reserved.
//

import Foundation

class Backgrounds {
    
    var id: Int?
    var order: Int?
    var file: String?
    var file_url: String?
    var type: String?
    var name: String?
    
    init(dictionary: [String:Any]) {
        if let id = dictionary["id"] as? Int {
            self.id = id
        }
        if let order = dictionary["order"] as? Int {
            self.order = order
        }
        if let file = dictionary["file"] as? String {
            self.file = file
        }
        if let file_url = dictionary["file_url"] as? String {
            self.file_url = file_url
        }
        if let type = dictionary["type"] as? String {
            self.type = type
        }
        if let name = dictionary["name"] as? String {
            self.name = name
        }
    }
}
