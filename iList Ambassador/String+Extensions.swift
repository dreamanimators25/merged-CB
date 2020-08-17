//
//  String+Extensions.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-05-17.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

extension String {
    
    func replace(_ string: String, replacement: String) -> String {
        return replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return replace(" ", replacement: "")
    }
    
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
}
