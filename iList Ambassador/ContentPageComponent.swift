//
//  ContentPageComponent.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 21/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import AVFoundation
import UIKit

private let kAPIKeyId = "id"
private let kAPIKeyType = "type"
private let kAPIKeyFile = "file"
private let kAPIKeyThumb = "thumbnail"
private let kAPIKeyMarginHorizontalPercent = "margin_horizontal"
private let kAPIKeyMarginBottomPercent = "margin_bottom"
private let kAPIKeyMarginEdgePercentage = "margin_edge_percentage"

private let kAPIKeyMeta = "meta"
private let kAPIKeyOrder = "order"
private let kAPIKeyContentPage = "content_page"
private let kAPIKeyCreated = "created"
private let kAPIKeyUpdated = "updated"

//META
private let kAPIKeyMetaBoxColor = "box_color"
private let kAPIKeyMetaColor = "color"
private let kAPIKeyMetaRoundedBox = "rounded_box"
private let kAPIKeyMetaBackgroundBox = "background_box"
private let kAPIKeyMetaTextAlign = "text_align"
private let kAPIKeyMetaText = "text"
private let kAPIKeyMetaFontWeight = "font_weight"
private let kAPIKeyMetaOpacity = "opacity"
private let kAPIKeyMetaFontStyle = "font_style"
private let kAPIKeyMetaFontSize = "font_size"

//Font Weights
private let bold = "bold"
private let normal = "normal"
private let italic = "italic"
private let semiTitle = "semi-title"
private let title = "title"


private let kAPIKeyMetaHeight = "height"
private let kAPIKeyMetaWidth = "width"
private let kAPIYoutubeUrl = "embed_url"
private let kAPIWider = "is_wider"
private let kAPIEmbedType = "embed_type"
private let kAPIThumbnailSize = "thumbnail_size"
private let kAPIMAarginEdgePerc = "margin_edge_percentage"
private let kAPIShareable = "shareable"
private let kAPIFileSize = "file_size"
private let kAPIMarginBottom = "margin_bottom"


open class ContentPageComponent {
    
    var id: Int = 0
    var type: ContentPageComponentType
    var file: String?
    var thumb: String?
    var youtubeUrl: String?
    var wider: String?
    var embedType: String?
    var marginBottom: String?
    var meta: Meta?
    var order: Int = 0
    var contentPage: Int = 0
    static var iden: String?
    
    var marginHorizontalPercent: CGFloat = 0.0
    var marginBottomPercent: CGFloat = 0.0
    var marginEdgePercentage: CGFloat = 0.0
    
    var created: Date?
    var updated: Date?
    
    convenience init(dictionary: [String:Any], identity: String?) {
        self.init(dictionary: dictionary)
        ContentPageComponent.iden = identity
    }
    
    init(dictionary: [String:Any]) {
    
        if let id = dictionary[kAPIKeyId] as? Int {
            self.id = id
        }
        
        self.type = ContentPageComponentType(rawValue: dictionary[kAPIKeyType] as! String)!
        
        if type == .Embed {
            parseEmbedType(dict: dictionary)
        }
        
//        if let url = dictionary[kAPIYoutubeUrl] {
//            self.youtubeUrl = url as! String
//        }
        
        if let file = dictionary[kAPIKeyFile] as? String {
            if self.type == .Video || self.type == .Sound {
                self.file = file
                let item = AVPlayerItem(url: URL(string: file)!)
                let player = Player(playerItem: item)
                MPCacher.sharedInstance.setObjectForKey(player, key: file)
            } else {
                self.file = file
            }
        }
        
        if let thumb = dictionary[kAPIKeyThumb] as? String {
            self.thumb = thumb
        }

        if let meta = dictionary[kAPIKeyMeta] as? [String:Any] {
            
            var BGBoxBool = ""
            var BGBoxColor = UIColor.clear
            var BGBoxRoundedBool = ""
            var text = ""
            var textColor = UIColor.clear
            var opacty : CGFloat = 0.0
            
            if let metaBGBoxBool = meta[kAPIKeyMetaBackgroundBox] as? String {
                BGBoxBool = metaBGBoxBool
            }
            
            if let metaBgColor = meta[kAPIKeyMetaBoxColor] as? String {
                BGBoxColor = UIColor(hexString: metaBgColor)
            }
            
            if let metaBgRound = meta[kAPIKeyMetaRoundedBox] as? String {
                BGBoxRoundedBool = metaBgRound
            }
            
            if let metaDataText = meta[kAPIKeyMetaText] as? String {
                text = metaDataText
            }
            
            if let metaDataColor = meta[kAPIKeyMetaColor] as? String {
                textColor = UIColor(hexString: metaDataColor)
            }
            
            var textAlignment = NSTextAlignment.center
            if let alignmentString = meta[kAPIKeyMetaTextAlign] as? String {
                switch alignmentString {
                case "left":
                    textAlignment = .left
                case "center":
                    textAlignment = .center
                case "right":
                    textAlignment = .right
                default:
                    break
                }
            }
            
            var fontSize : CGFloat = 14.0
            if let metaDataFontSize = meta[kAPIKeyMetaFontSize] as? String {
                fontSize = CGFloat(NSString(string: metaDataFontSize).floatValue)
            }
            
            var fontStyle = ""
            if let fntStyle = meta[kAPIKeyMetaFontStyle] as? String {
                 fontStyle = fntStyle
            }
            var fontWeight = ""
            if let metaDataFontWeight = meta[kAPIKeyMetaFontWeight] as? String {
                fontWeight = metaDataFontWeight
            }
            
            var font = Font.normalFont(fontSize)
            if fontWeight == normal && fontStyle == normal {
                font = Font.normalFont(fontSize)
            }else if fontWeight == normal && fontStyle == "" {
                font = Font.normalFont(fontSize)
            }else if fontWeight == "" && fontStyle == "" {
                font = Font.normalFont(fontSize)
            }else if fontWeight == bold && fontStyle == normal {
                font = Font.boldFont(fontSize)
            }else if fontWeight == bold && fontStyle == "" {
                font = Font.boldFont(fontSize)
            }else if fontWeight == normal && fontStyle == italic {
                font = Font.italicFont(fontSize)
            }else if fontWeight == "" && fontStyle == italic {
                font = Font.italicFont(fontSize)
            }else if fontWeight == bold && fontStyle == italic {
                font = Font.boldItalicFont(fontSize)
            }
            
            /*
            var font = Font.normalFont(fontSize)
            if let metaDataFontWeight = meta[kAPIKeyMetaFontWeight] as? String {
                switch metaDataFontWeight {
                case bold:
                    font = Font.boldFont(fontSize)
                case italic:
                    font = Font.italicFont(fontSize)
                case semiTitle:
                    font = Font.semiTitleFont(fontSize)
                case title:
                    font = Font.titleFont(fontSize)
                default:
                    break
                }
            }*/
            
            if let bgOpact = meta[kAPIKeyMetaOpacity] as? String {
                if let op = NumberFormatter().number(from: bgOpact) {
                    opacty = CGFloat(truncating: op)
                }
            }
            
            var height:CGFloat = 0.0
            if let metaDataHeight = meta[kAPIKeyMetaHeight] as? String {
                height = CGFloat(NSString(string: metaDataHeight).floatValue)
            }
            
            var width:CGFloat = 0.0
            if let metaDataWidth = meta[kAPIKeyMetaWidth] as? String {
                width = CGFloat(NSString(string: metaDataWidth).floatValue)
            }
            
            self.meta = Meta(font: font, color: textColor, bgColor: BGBoxColor, bgOpacity: opacty, bgBox: BGBoxBool, text: text, height: height, width: width, textAlignment: textAlignment, backRound: BGBoxRoundedBool)
            
        }
        
        if let order = dictionary[kAPIKeyOrder] as? Int {
            self.order = order
        }
        
        if let contentPage = dictionary[kAPIKeyContentPage] as? Int {
            self.contentPage = contentPage
        }
        
        if let marginHorizontalPercent = dictionary[kAPIKeyMarginHorizontalPercent] as? Float {
            self.marginHorizontalPercent = CGFloat(marginHorizontalPercent)
        }
        
        if let marginBottom = dictionary[kAPIKeyMarginBottomPercent] as? Float {
            self.marginBottomPercent = CGFloat(marginBottom)
        }

        if let createdString = dictionary[kAPIKeyCreated] as? String, let createdDate = NSDate(string: createdString, formatString: APIDefinitions.FullDateFormat) {
            created = createdDate as Date
        }
        
        if let updatedString = dictionary[kAPIKeyUpdated] as? String, let updatedDate = NSDate(string: updatedString, formatString: APIDefinitions.FullDateFormat) {
            updated = updatedDate as Date
        }
        
        //print("ident1 = \(self.type), ident2 = \(ContentPageComponent.iden)")
        
    }
}

// MARK: - Parse embed type
extension ContentPageComponent {
    
    func parseEmbedType(dict: [String : Any]) {
        
        if let url = dict[kAPIYoutubeUrl] {
            self.youtubeUrl = url as? String
        }
        
        if let marginBottom = dict[kAPIMarginBottom] {
            self.marginBottom = marginBottom as? String
        }
        
        if let wider = dict[kAPIWider] {
            self.wider = wider as? String
        }
        
        if let embedType = dict[kAPIEmbedType] {
            self.embedType = embedType as? String
        }
    }
}


struct Meta {
    
    var text: String
    var font: UIFont
    var color: UIColor
    var textAlignment: NSTextAlignment
    //var style: String
    //var size: CGFloat
    
    var background_box : String
    var bgBoxRound : String
    var bgBoxColor: UIColor
    var bgBoxOpacity : CGFloat
    
    var height: CGFloat
    var width: CGFloat
    

    init(font: UIFont, color: UIColor, bgColor: UIColor, bgOpacity: CGFloat , bgBox: String, text: String, height: CGFloat,width: CGFloat, textAlignment: NSTextAlignment, backRound : String) {
        
        self.font = font
        //self.size = size
        //self.style = styl
        self.color = color
        self.text = text
        self.textAlignment = textAlignment
        
        self.bgBoxColor = bgColor
        self.background_box = bgBox
        self.bgBoxOpacity = bgOpacity
        self.bgBoxRound = backRound
        
        self.height = height
        self.width = width
        
    }
}








