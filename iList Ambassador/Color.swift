//
//  Color.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 10/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class Color {
    class func RGBA(_ red: CGFloat,   green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor { return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha) }
    
    class func backgroundColorDark() -> UIColor { return UIColor(hexString: "222b2f") }
    class func backgroundColorFadedDark() -> UIColor { return UIColor(hexString: "2c353a") }
    
    class func backgroundColorWhite() -> UIColor { return UIColor.white }
    class func backgroundColorGray() -> UIColor { return UIColor(hexString: "edf1f2") }
    
    
    class func lightGrayColor() -> UIColor { return UIColor(hexString: "B7B6BB") }
    class func grayColor() -> UIColor { return UIColor(hexString: "cccccc") }
    class func darkGrayColor() -> UIColor { return UIColor(hexString: "4c4c4c") }
    
    class func blackColor() -> UIColor { return UIColor.black }
    class func whiteColor() -> UIColor { return UIColor.white }
    class func blueColor() -> UIColor { return self.RGBA(44.0, green: 114.0, blue: 183.0, alpha: 1.0) }
    class func lightBlueColor() -> UIColor { return self.RGBA(138, green: 196, blue: 252, alpha: 1.0) }
    class func ilistBackgroundColor() -> UIColor { return UIColor(hexString: "393a54") }

    class func transparentBlueColor() -> UIColor { return self.RGBA(44.0, green: 114.0, blue: 183.0, alpha: 0.8) }
    class func purpleColor() -> UIColor { return UIColor(hexString: "393b54") }
    class func redColor() -> UIColor { return UIColor(hexString: "ff0000") }
    
    class func textColorDark() -> UIColor { return UIColor.darkText }
    class func textColorLight() -> UIColor { return UIColor.lightText }
    
    class var newGray: UIColor { return UIColor(hexString: "#63666A") }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
