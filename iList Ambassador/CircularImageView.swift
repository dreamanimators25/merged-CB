//
//  CircularImageView.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 06/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class CircularImageView: UIImageView {

    var maskview = UIImageView()
        
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
        //layer.masksToBounds = true
        maskview.image = UIImage(named: "PolygonMask")
        maskview.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.mask = maskview
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        maskview.contentMode = .scaleAspectFit
        maskview.frame = self.bounds
        //layer.cornerRadius = bounds.width/2.0
    }
    
}
