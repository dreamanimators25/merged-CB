//
//  ConnectionRequestTableViewCell.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 27/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

protocol ConnectionRequestTableViewCellDelegate {
    func didTapAcceptButtonForConnectionRequestTableViewCell(_ cell: ConnectionRequestTableViewCell)
    func didTapDeclineButtonForConnectionRequestTableViewCell(_ cell: ConnectionRequestTableViewCell)
    func didTapCancelButtonForConnectionRequestTableViewCell(_ cell: ConnectionRequestTableViewCell)
}

class ConnectionRequestTableViewCell: UITableViewCell {

    static let cellIdentifier = "ConnectionRequestTableViewCell"
    static let cellHeight = CGFloat(224.0)
    
    var delegate: ConnectionRequestTableViewCellDelegate?
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var profilePictureImageView: ProfilePictureImageView!
    @IBOutlet weak var nameLabel: Label!
    @IBOutlet weak var infoLabel: Label!
    
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = CornerRadius.Default
        
        nameLabel.font = Font.titleFont(FontSize.ExtraLarge)
        nameLabel.textColor = Color.blackColor()
        infoLabel.font = Font.normalFont(FontSize.Large)
        infoLabel.textColor = Color.blackColor()
        
        acceptButton.setTitleColor(Color.ilistBackgroundColor(), for: UIControl.State())
        declineButton.setTitleColor(Color.ilistBackgroundColor(), for: UIControl.State())
        cancelButton.setTitleColor(Color.ilistBackgroundColor(), for: UIControl.State())
        acceptButton.titleLabel?.font = Font.titleFont(FontSize.Large)
        declineButton.titleLabel?.font = Font.titleFont(FontSize.Large)
        cancelButton.titleLabel?.font = Font.titleFont(FontSize.Large)
        
        /*acceptButton.setTitle(NSLocalizedString("ACCEPT", comment: "").uppercased(), for: UIControlState())
        declineButton.setTitle(NSLocalizedString("DECLINE", comment: "").uppercased(), for: UIControlState())*/
        cancelButton.setTitle(NSLocalizedString("CANCEL", comment: "").uppercased(), for: UIControl.State())
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePictureImageView.prepareForReuse()
        nameLabel.text = nil
    }
    
    // MARK: - Connection
    
    func updateWithConnectionRequest(_ connectionRequest: ConnectionRequest) {
        acceptButton.isHidden = connectionRequest.isCurrentUsersRequest
        declineButton.isHidden = connectionRequest.isCurrentUsersRequest
        
        cancelButton.isHidden = !connectionRequest.isCurrentUsersRequest
        
        if connectionRequest.isCurrentUsersRequest {
            profilePictureImageView.setImageForUser(connectionRequest.toUser)
            nameLabel.text = "\( connectionRequest.toUser.fullName )"
            //infoLabel.text = NSLocalizedString("CONNECTION_REQUEST_WAITING_FOR_USER", comment: "")
            infoLabel.text = ""
        } else {
            profilePictureImageView.setImageForUser(connectionRequest.fromUser)
            nameLabel.text = "\( connectionRequest.fromUser.fullName )"
            //infoLabel.text = NSLocalizedString("CONNECTION_REQUEST_WANTS_TO_CONNECT", comment: "")
            infoLabel.text = ""
        }
    }
    
    // MARK: - Actions
    
    @IBAction func declineButtonTapped(_ sender: AnyObject) {
        delegate?.didTapDeclineButtonForConnectionRequestTableViewCell(self)
    }
    
    @IBAction func acceptButtonTapped(_ sender: AnyObject) {
        delegate?.didTapAcceptButtonForConnectionRequestTableViewCell(self)
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        delegate?.didTapCancelButtonForConnectionRequestTableViewCell(self)
    }
    
}
