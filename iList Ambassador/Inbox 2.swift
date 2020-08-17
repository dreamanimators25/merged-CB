//
//  Inbox.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-08-12.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation

private let kAPIKeyId = "id"
private let kAPIKeyTitle = "title"
private let kAPIKeyBrand = "brand"
    private let kAPIKeyName = "name"
    private let kAPIKeyImg = "logotype"
    private let kAPIKeyBg = "background"

open class Inbox {
    
    var contentId: Int?
    var title: String?
    var brandName: String?
    var brandImg: String?
    var brandBg: String?
    
    init(dict: [String:Any]) {
        if let id = dict[kAPIKeyId] as? Int {
            self.contentId = id
        }
        if let title = dict[kAPIKeyTitle] as? String {
            self.title = title
        }
        if let brand = dict[kAPIKeyBrand] as? [String:Any] {
            if let name = brand[kAPIKeyName] as? String {
                self.brandName = name
            }
            if let img = brand[kAPIKeyImg] as? String {
                self.brandImg = img
            }
            if let bg = brand[kAPIKeyBg] as? String {
                self.brandBg = bg
            }
        }
    }
}
