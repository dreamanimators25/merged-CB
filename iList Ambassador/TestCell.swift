//
//  TestCell.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-07-31.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class RewardCell: UICollectionViewCell {
    
    @IBOutlet weak var logotype: HexagonalImageView!
    
    @IBOutlet weak var icon: HexagonalImageView!
    
    
    
    var cellReward: RewardList? {
        didSet {
            if let reward = cellReward {
                // TODO: Change URL to logotype URL
                logotype.af_setImage(withURL: reward.brand.logotype)
                // TODO: Set proper icon image download
                icon.af_setImage(withURL: reward.iconUrl)
                
            }
        }
    }
}
