//
//  CircularView.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 24/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class CircularView: UIView {

    // MARK: - View life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width/2.0
    }

}
