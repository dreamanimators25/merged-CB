//
//  ContentPageComponentButton.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 12/06/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class ContentPageComponentButton: Button, ContentPageComponentProtocol {
    
    var touchUpInsideBlock: (()->Void)?
    
    var heightConstraint: NSLayoutConstraint?
    var calculatedHeight: CGFloat = 44.0
    var prefferdMargin:CGFloat = 0.3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init(customTitle: String, touchUpInsideBlock: (()->Void)? = nil) {
        self.init(frame: CGRectZero)
        self.touchUpInsideBlock = touchUpInsideBlock
        setTitle(customTitle, forState: .Normal)
        setup()
    }
        
    func setup() {
        backgroundColor = Color.transparentBlueColor()
        titleColor = Color.whiteColor()
        titleLabel?.font = Font.titleFont(FontSize.Large)
        
        heightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: .None, attribute: .NotAnAttribute, multiplier: 1.0, constant: calculatedHeight)
        addConstraint(heightConstraint!)
        
        addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
    }
    
    func buttonPressed(sender: UIButton) {
        touchUpInsideBlock?()
    }
    func reset() {
        
    }
    
    // MARK: - ContentPageComponentProtocol
    
    func view() -> UIView {
        return self
    }
    
    func updateWithHeightConstraint(heightConstraint: NSLayoutConstraint) {
        
    }
    
    func updateHeightForComponentWithWidth(width: CGFloat) {
        
    }
    
    func prefferedMargin() -> CGFloat {
        return self.prefferdMargin
    }
    
    func prepareForReuse() {
        
    }
}
