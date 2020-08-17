//
//  FriendsTableViewCell.swift
//  iList Ambassador
//
//  Created by Dmitriy Zhyzhko on 10.03.2019.
//  Copyright © 2019 iList AB. All rights reserved.
//

import Foundation
import UIKit

protocol FriendsTableViewCellDelegate {
    func plusPressed(user: User?)
    func minusPressed(user: User?)
    
}

final class FriendsTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var imageWidhtConstraint: NSLayoutConstraint!
    
    var user: User?
    var connect: Connection?
    var connectRequest: ConnectionRequest?
    
    var delegate1: FriendsTableViewCellDelegate1?
    var delegate2: FriendsTableViewCellDelegate2?
    
    @IBAction func minusPressed(_ sender: Any) {
        print("del = \(delegate1)")
        delegate1?.minusPressed(user: connectRequest)
        delegate2?.minusPressed(user: connect)
    }
    
    @IBAction func plusPressed(_ sender: Any) {
        delegate1?.plusPressed(user: connectRequest)
        delegate2?.plusPressed(user: connect)
    }
    
    @IBAction func removeGroupClicked(_ sender: UIButton) {
        delegate2?.removeGroup(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
}
