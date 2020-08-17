//
//  InfluencerCell.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-08-14.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit

class InfluencerCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: HexagonalImageView!
    
    var setImage: Bool? {
        didSet {
            if setImage == true {
                imageView.image = #imageLiteral(resourceName: "Polygon")
            }
            else { imageView.image = #imageLiteral(resourceName: "Polygon") /*imageView.image = #imageLiteral(resourceName: "PolygonMask")*/ }
        }
    }
}
