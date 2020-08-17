//
//  Definitions.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 10/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import UIKit

public struct APIDefinitions {
    static let FullDateFormat: String = "yyyy-MM-dd HH:mm:ssZ"
}

public struct CornerRadius {
    static let Default: CGFloat = 4.0
    static let Large: CGFloat = 8.0
}

public struct FontSize {
    static let Mini: CGFloat = 9.0
    static let Small: CGFloat = 11.0
    static let Normal: CGFloat = 13.0
    static let Large: CGFloat = 15.0
    static let ExtraLarge: CGFloat = 18.0
    static let SuperLarge: CGFloat = 22.0
    static let Mega: CGFloat = 32.0
}


public struct ErrorMessages {
    static var TooManyHashtagsMessage: String = Localization.translate("MAXIMUM_7_HASHTAGS")
    static var InvalidLinkFormat: String = Localization.translate("INVALID_LINK_FORMAT")
    static var OnlyCharactersInHashtagMessage: String = Localization.translate("ONLY_ALPHANUMERIC_CHARACTERS_IN_HASHTAG")
}

public enum LoginService: Int {
    case facebook = 0
    case twitter = 1
    case email = 2
}

/* User */
public enum Gender: String {
    case Unspecified = "unspecified"
    case Male = "male"
    case Female = "female"
}

/* Offers */
public enum OfferPermission: Int {
    case noAction = 0
    case claimable = 1
    case sharable = 2
    case claimableAndShareable = 3
}

public enum ConsumeAction: Int {
    case information = 0
    case onlyConsumable = 1
    case link = 2
    case code = 3
    case affiliate = 4
    case document = 5
    case phone = 6
    case email = 7
    case multiLink = 8

    
    var contentButtonTitle: String {
        switch self {
        case .information:
            return NSLocalizedString("INFORMATION", comment: "")
        case .onlyConsumable:
            return NSLocalizedString("USE", comment: "")
        case .link, .document:
            return NSLocalizedString("OPEN", comment: "")
        case .code:
            return NSLocalizedString("CODE", comment: "")
        case .affiliate:
            return NSLocalizedString("AFFILIATE", comment: "")
        case .phone:
            return NSLocalizedString("PHONE", comment: "")
        case .email:
            return NSLocalizedString("EMAIL", comment: "")
        case .multiLink:
            return NSLocalizedString("MULTILINK", comment: "")
    }
    }
}

//added new content type to avoid crash
public enum ContentPageComponentType: String {
    case Text = "text"
    case Image = "image"
    case Video = "video"
    case Sound = "sound"
    case Embed = "embed"
}

public enum ContentPageBackgroundType: String {
    case Color = "color"
    case Image = "image"
    case Video = "video"
}

public enum ConnectionRequestAction: String {
    case View = "view"
    case Accept = "accept"
    case Reject = "reject"
    case Cancel = "cancel"
}

public enum ContentConsumeDataType: Int {
    case code = 2
    case link = 1
    case other = 0
}

public enum OfferMediaType: Int {
    case image = 0
    case video = 1
}

public enum SocialMedia: Int {
    case facebook = 1
    case twitter = 2
    case instagram = 3
}

/* Personal recommendation */
public enum ReportType: Int {
    case fakeUser = 0
    case notARecommendation = 1
    case explicitRecommendation = 2
    case badLink = 3
    case other = 4
}

enum DataLoadState<T> {
    case loading
    case failed(reason: String)
    case loaded(T)
}

struct Platform {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
    }
    
    static var currentAppversion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
}

let SCREENSIZE = UIScreen.main.bounds

public func backgroundThread(_ delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
    
    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
        if(background != nil){ background!(); }
        
        let popTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            if(completion != nil){ completion!(); }
        }
    }
}
public func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

