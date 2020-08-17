//
//  RewardPageBackground.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-08-09.
//  Copyright © 2017 iList AB. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

private let kAPIKeyId = "id"
private let kAPIKeyType = "type"
private let kAPIKeyFile = "file"
private let kAPIKeyMeta = "meta"
private let kAPIKeyContentPage = "content_page"
private let kAPIKeyCreated = "created"
private let kAPIKeyUpdated = "updated"

open class RewardPageBackground {
    
    var id: Int = 0
    var type: ContentPageBackgroundType
    var file: String?
    var meta = backgroundMeta(color: "Balle")
    var contentPage: Int = 0
    
    var created: Date?
    var updated: Date?
    var video: AVPlayerItem?
    var videoThumb: UIImage?
    var fileUrl: String?
    
    init(dictionary: [String:Any]) {
        if let fileurl = dictionary["file_url"] as? String {
            self.fileUrl = fileurl
        }
        if let id = dictionary[kAPIKeyId] as? Int {
            self.id = id
        }
        self.type = ContentPageBackgroundType(rawValue: dictionary[kAPIKeyType] as! String)!
        
        if let file = dictionary[kAPIKeyFile] as? String {
            if self.type == .Video {
                self.file = file
                let item = AVPlayerItem(url: URL(string: file)!)
                let player = Player(playerItem: item)
                player.isMuted = true
                MPCacher.sharedInstance.setObjectForKey(player, key: file)
            } else {
                self.file = file
            }
        }
        if let meta = dictionary[kAPIKeyMeta] as? [String:Any] {
            
            var color = String()
            if let thecolor = meta["color"] as? String {
                color = thecolor
            }
            self.meta.color = color
        }
        if let contentPage = dictionary[kAPIKeyContentPage] as? Int {
            self.contentPage = contentPage
        }
        if let createdString = dictionary[kAPIKeyCreated] as? String, let createdDate = NSDate(string: createdString, formatString: APIDefinitions.FullDateFormat) {
            created = createdDate as Date
        }
        if let updatedString = dictionary[kAPIKeyUpdated] as? String, let updatedDate = NSDate(string: updatedString, formatString: APIDefinitions.FullDateFormat) {
            updated = updatedDate as Date
        }
    }
}

struct backgroundMeta {
    
    var color: String
    
    init(color: String) {
      self.color = color
    }
}
