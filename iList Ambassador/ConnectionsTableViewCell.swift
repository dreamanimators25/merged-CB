//
//  ConnectionsTableViewCell.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 09/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

protocol ConnectionsTableViewCellDelegate {
    func didTapDeleteButtonForCell(_ cell: ConnectionsTableViewCell)
}

class ConnectionsTableViewCell: UITableViewCell {

    var delegate: ConnectionsTableViewCellDelegate?
    
    static let cellIdentifier = "ConnectionsTableViewCell"
    static let cellHeight = CGFloat(100.0)
    
    @IBOutlet weak var profilePictureImageView: ProfilePictureImageView!
    @IBOutlet weak var nameLabel: Label!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.font = Font.titleFont(FontSize.Large)
        nameLabel.textColor = Color.ilistBackgroundColor()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePictureImageView.prepareForReuse()
        nameLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - Connection 
    
    func updateWithConnection(_ connection: Connection) {
        nameLabel.text = connection.toUser.fullName
        profilePictureImageView.setImageForUser(connection.toUser)
    }
    
    // MARK: - Actions
    
    @IBAction func deleteButtonTapped(_ sender: AnyObject) {
        delegate?.didTapDeleteButtonForCell(self)
    }
    
}
