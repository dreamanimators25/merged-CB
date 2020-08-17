//
//  BadgeCell.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-08-14.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit

class BadgeCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: HexagonalImageView!
    
    
    var badge: Badge? {
        didSet {
            if badge != nil {
                imageView.af_setImage(withURL: (badge?.brandBadge.badge)!)
            }
        }
    }
}
