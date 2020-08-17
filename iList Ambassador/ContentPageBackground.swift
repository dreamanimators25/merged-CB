//
//  ContentPageBackground.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 21/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

private let kAPIKeyId = "id"
private let kAPIKeyType = "type"
private let kAPIKeyFile = "file"
private let kAPIKeyFileURL = "file_url"
private let kAPIKeyMeta = "meta"
private let kAPIKeyContentPage = "content_page"
private let kAPIKeyCreated = "created"
private let kAPIKeyUpdated = "updated"
private let kAPIKeyOrder = "order"

private let kAPIKeyColor = "color"
private let kAPIKeyRounded_box = "rounded_box"
private let kAPIKeyBackground_box = "background_box"
private let kAPIKeyText_align = "text_align"
private let kAPIKeyText = "text"
private let kAPIKeyOpacity = "opacity"
private let kAPIKeyFont_size = "font_size"
private let kAPIKeyBox_color = "box_color"

open class ContentPageBackground {
    
    var id: Int = 0
    var type: ContentPageBackgroundType
    var file_url: String?
    var file: String?
    var meta: [String:Any]?
    var contentPage: Int = 0
    var order: Int = 0
    
    var created: Date?
    var updated: Date?
    var video: AVPlayerItem?
    var videoThumb: UIImage?
    
    init(dictionary: [String:Any]) {
        if let id = dictionary[kAPIKeyId] as? Int {
            self.id = id
        }
        //print("typessss = \(dictionary[kAPIKeyType])")
        self.type = ContentPageBackgroundType(rawValue: dictionary[kAPIKeyType] as! String)!
        
//        print("type huy = \(type), \(dictionary[kAPIKeyFile]), \(dictionary[kAPIKeyFileURL])")
//
        if let fileurl = dictionary[kAPIKeyFileURL] as? String {
            self.file_url = fileurl
            if self.type == .Video {
                let item = AVPlayerItem(url: URL(string: fileurl)!)
                let player = Player(playerItem: item)
                player.isMuted = true
                MPCacher.sharedInstance.setObjectForKey(player, key: fileurl)
            } else {
                self.file_url = fileurl
            }
        }
        
        if let file = dictionary[kAPIKeyFile] as? String {
            self.file = file
            if self.type == .Video {
                let item = AVPlayerItem(url: URL(string: file)!)
                let player = Player(playerItem: item)
                player.isMuted = true
                MPCacher.sharedInstance.setObjectForKey(player, key: file)
            } else {
                self.file = file
            }
            
        }
        if let meta = dictionary[kAPIKeyMeta] as? [String:Any] {
            self.meta = meta
        }
        if let contentPage = dictionary[kAPIKeyContentPage] as? Int {
            self.contentPage = contentPage
        }
        if let order = dictionary[kAPIKeyOrder] as? Int {
            self.order = order
        }
        if let createdString = dictionary[kAPIKeyCreated] as? String, let createdDate = NSDate(string: createdString, formatString: APIDefinitions.FullDateFormat) {
            created = createdDate as Date
        }
        if let updatedString = dictionary[kAPIKeyUpdated] as? String, let updatedDate = NSDate(string: updatedString, formatString: APIDefinitions.FullDateFormat) {
            updated = updatedDate as Date
        }
    }
}

open class ConsumeActionComponents {
    
    var color : String?
    var roundedBox : String?
    var backGroundBox : String?
    var textAlign : String?
    var text : String?
    var opacity : String?
    var fontSize : String?
    var boxColor : String?
    
    
    init(dictionary: [String:Any]) {
        if let col = dictionary[kAPIKeyColor] as? String {
            self.color = col
        }
        if let roundBoc = dictionary[kAPIKeyRounded_box] as? String {
            self.roundedBox = roundBoc
        }
        if let backBox = dictionary[kAPIKeyBackground_box] as? String {
            self.backGroundBox = backBox
        }
        if let txtAlign = dictionary[kAPIKeyText_align] as? String {
            self.textAlign = txtAlign
        }
        if let txt = dictionary[kAPIKeyText] as? String {
            self.text = txt
        }
        if let opct = dictionary[kAPIKeyOpacity] as? String {
            self.opacity = opct
        }
        if let fntSize = dictionary[kAPIKeyFont_size] as? String {
            self.fontSize = fntSize
        }
        if let boccolor = dictionary[kAPIKeyBox_color] as? String {
            self.boxColor = boccolor
        }
    }

}
