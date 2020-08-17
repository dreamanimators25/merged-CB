//
//  ShadowLabel.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 06/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class ShadowLabel: UILabel {

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
        layer.masksToBounds = false
        updateColors()
    }
    
    fileprivate func updateColors() {
        textColor = Color.whiteColor()
        shadowColor = UIColor(white: 0.0, alpha: 0.3)
        shadowOffset = CGSize(width: 2, height: 2)
    }

}
