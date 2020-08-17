//
//  Label.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 09/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class Label: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
   
    fileprivate func setup() {
        setNormalStyle()
    }
    
    func setNormalStyle() {
        font = Font.normalFont(FontSize.Normal)
        textColor = Color.textColorDark()
    }
    
    func setTitleStyle() {
        font = Font.normalFont(FontSize.Large)
        textColor = Color.blueColor()
    }
    
    func setSubtitleStyle() {
        font = Font.normalFont(FontSize.Normal)
        textColor = Color.textColorDark()
    }
    
    func setErrorStyle() {
        font = Font.italicFont(FontSize.Small   )
        textColor = Color.redColor()
    }
    
    func updateWithAttributedStrings(_ attributedStrings: [NSAttributedString]) {
        let attributedString = NSMutableAttributedString()
        attributedStrings.forEach({
            attributedString.append($0)
        })
        attributedText = attributedString
    }
    
}

class ErrorLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        font = Font.italicFont(font.pointSize)
        textColor = Color.redColor()
    }
}

class NormalLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        font = Font.normalFont(font.pointSize)
    }
}

class ItalicLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        font = Font.italicFont(font.pointSize)
    }
}

class BoldLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        font = Font.boldFont(font.pointSize)
    }
}

class TitleLabel: UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        font = Font.titleFont(font.pointSize)
    }
}
