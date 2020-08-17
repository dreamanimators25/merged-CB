//
//  Font.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 10/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class Font {

//    class func blackFont(size: CGFloat) -> UIFont { return UIFont(name: "Lato-Black", size: size)! }
//    class func boldFont(size: CGFloat) -> UIFont { return UIFont(name: "Lato-Bold", size: size)! }
//    class func italicFont(size: CGFloat) -> UIFont { return UIFont(name: "Lato-Italic", size: size)! }
//    class func lightFont(size: CGFloat) -> UIFont { return UIFont(name: "Lato-Light", size: size)! }
//    class func lightItalicFont(size: CGFloat) -> UIFont { return UIFont(name: "Lato-LightItalic", size: size)! }
//    class func normalFont(size: CGFloat) -> UIFont { return UIFont(name: "Lato-Regular", size: size)! }
//    class func semiBoldFont(size: CGFloat) -> UIFont { return UIFont(name: "Lato-Semibold", size: size)! }

    
    class func normalFont(_ size: CGFloat) -> UIFont { return UIFont(name: "Helvetica", size: size)! }
    class func boldFont(_ size: CGFloat) -> UIFont { return UIFont(name: "Helvetica-Bold", size: size)! }
    
    class func italicFont(_ size: CGFloat) -> UIFont { return UIFont(name: "Helvetica-LightOblique", size: size)! }
    
    class func titleFont(_ size: CGFloat) -> UIFont { return UIFont(name: "MyriadPro-BoldSemiCn", size: size)! }
    class func semiTitleFont(_ size: CGFloat) -> UIFont { return UIFont(name: "MyriadPro-SemiboldSemiCn", size: size)! }
    
    
    //        class func titleFont(size: CGFloat) -> UIFont { return UIFont(name: "MyriadPro-Regular", size: size)! }
    
    //        class func normalFont(size: CGFloat) -> UIFont { return UIFont(name: "MyriadPro", size: size)! }
    //        class func lightFont(size: CGFloat) -> UIFont { return UIFont(name: "MyriadPro-Light", size: size)! }
    //        class func titleFont(size: CGFloat) -> UIFont { return UIFont(name: "MyriadPro-Light", size: size)! }
    
    //        class func boldFont() -> String { return "MyriadPro-Heavy" }
    //        class func italicFont() -> String { return "Avenir-BookOblique" }
    
}
