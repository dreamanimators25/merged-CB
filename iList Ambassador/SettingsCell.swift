//
//  SettingsCell.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-08-20.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var noGenderButton: UIButton!
    @IBOutlet weak var cellDetail: UILabel!
    
    var picture: UIImage? {
        didSet {
            if let cellPic = picture {
                cellImage.image = cellPic
            }
        }
    }
    
    var labelText: String? {
        didSet {
            if let text = labelText {
                cellLabel.text = text
                cellLabel.textColor = Color.newGray
            }
        }
    }
}
