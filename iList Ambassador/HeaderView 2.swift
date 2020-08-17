//
//  HeaderView.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-08-14.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
    
    
    
   
    
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var line: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var title: String? {
        didSet {
            titleLabel.text = title
            
        }
    }
}
