//
//  ContentPageComponentTextView.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 12/06/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class ContentPageComponentTextView : UITextView, ContentPageComponentProtocol {
    
    var heightConstraint: NSLayoutConstraint?
    var calculatedHeight: CGFloat = 80.0
    var prefferdMargin:CGFloat = 16.0
    var color: UIColor = UIColor.whiteColor()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init(text: String, font: UIFont, color: UIColor) {
        self.init()
        self.text = text
        self.font = font
        self.color = color
        setup()
    }
    func reset() {
        
    }
    private func setup() {
        backgroundColor = UIColor.clearColor()
        textColor = self.color
        textAlignment = .Center
        
        editable = false
        selectable = false
        scrollEnabled = false
        
        tintColor = Color.blueColor()
        
        // TODO: removed this constraint to fix constraint warnings
//        heightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: .None, attribute: .NotAnAttribute, multiplier: 1.0, constant: calculatedHeight)
//        addConstraint(heightConstraint!)
        
        textContainerInset = UIEdgeInsetsZero
        textContainer.lineFragmentPadding = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let heightConstraint = heightConstraint {
            heightConstraint.constant = calculatedHeight
        }
    }
    
    // MARK: - ContentPageComponentHeightProtocol
    
    func updateConstraintsForView() {
        if let heightConstraint = self.heightConstraint {
            heightConstraint.constant = self.calculatedHeight
        }
        self.layoutIfNeeded()
    }
    
    func view() -> UIView {
        return self
    }
    
    func updateWithHeightConstraint(heightConstraint: NSLayoutConstraint) {
        self.heightConstraint = heightConstraint
        updateConstraintsForView()
    }
    
    func updateHeightForComponentWithWidth(width: CGFloat) {
        let attributes: [String:AnyObject] = [NSFontAttributeName:self.font!]
        calculatedHeight = NSString(string: self.text).boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil).size.height + 20
        updateConstraintsForView()
    }
    
    func prefferedMargin() -> CGFloat {
        return self.prefferdMargin
    }
    
    func prepareForReuse() {
        text = nil
    }
    
}

