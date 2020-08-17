//
//  LevelCell.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-08-14.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit

class LevelCell: UICollectionViewCell {
    
    @IBOutlet weak var image: HexagonalImageView!
    
    var setImage: Bool? {
        didSet {
            if setImage == true {
                image.image = #imageLiteral(resourceName: "Polygon")
            }
            else { image.image = #imageLiteral(resourceName: "Polygon") /*image.image = #imageLiteral(resourceName: "PolygonMask")*/ }
        }
    }
}
