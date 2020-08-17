//
//  UserTableViewCell.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 21/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    static let cellIdentifier = "UserTableViewCell"
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
        nameLabel.font = UIFont(name: "MyriadPro-Regular", size: 15)
        nameLabel.textColor = UIColor.init(hexString: "4B23BD")
        
        profilePictureImageView.contentMode = .scaleAspectFill
        profilePictureImageView.clipsToBounds = true
        print("height = \(profilePictureImageView.frame.height)")
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePictureImageView.af_cancelImageRequest()
    }
    
}
