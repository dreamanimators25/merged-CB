//
//  ContentPageComponentImageView.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 12/06/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import Alamofire

class ContentPageComponentImageView : UIImageView {
    
    var heightConstraint: NSLayoutConstraint?
    var calculatedHeight: CGFloat = 180.0
    var prefferdMargin:CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init(imageUrlString: String) {
        self.init(frame: CGRectZero)
        if let imageUrl = NSURL(string: imageUrlString) {
            setImageFromUrl(imageUrl)
        }
    }
    
    private func setup() {
        backgroundColor = UIColor.clearColor()
        contentMode = .ScaleAspectFit
    }
    
    // MARK: - Image
    
    func setImageFromUrl(imageUrl: NSURL) {
        Alamofire.request(.GET, imageUrl)
            .responseImage { response in
                dispatch_async(dispatch_get_main_queue(), {
                    if let image = response.result.value {
                        self.image = image
                        //let Height = ((CGRectGetWidth(self.bounds)-20)/image.size.width)*image.size.height
                        //self.calculatedHeight = Height
                        //self.updateConstraintsForView()
                    }
                })
        }
        
    }
    
    func updateConstraintsForView() {
        if let heightConstraint = self.heightConstraint {
            heightConstraint.constant = self.calculatedHeight
        } else {
            let constraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: .None, attribute: .NotAnAttribute, multiplier: 1, constant: self.calculatedHeight)
            addConstraint(constraint)
        }
        self.layoutIfNeeded()
    }
    // MARK: - ContentPageComponentHeightProtocol
    
    func view() -> UIView {
        return self
    }
    func reset() {
        
    }
    func updateWithHeightConstraint(heightConstraint: NSLayoutConstraint) {
        self.heightConstraint = heightConstraint
        updateConstraintsForView()
    }
    
    func updateHeightForComponentWithWidth(width: CGFloat) {
        // Not used here..
    }

    func prefferedMargin() -> CGFloat {
        return self.prefferdMargin
    }
    
    func prepareForReuse() {
        image = nil
    }
    
}
