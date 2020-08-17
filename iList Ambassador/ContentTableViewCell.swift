//
//  ContentTableViewCell.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 16/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import AlamofireImage

class ContentTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "ContentTableViewCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backgroundImageView: BackgroundImageView!
    @IBOutlet weak var profilePictureImageView: ProfilePictureImageView!
    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var nameLabel: Label!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = CornerRadius.Large
        backgroundImageView.alpha = 0.4
        
        
        titleLabel.font = Font.boldFont(FontSize.Large)
        titleLabel.textColor = Color.purpleColor()
        
        titleLabel.font = Font.boldFont(FontSize.Large)
        titleLabel.textColor = Color.textColorDark()
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundImageView.prepareForReuse()
        profilePictureImageView.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let alpha = CGFloat(selected ? 0.4 : 1.0)
        containerView.alpha = alpha
        profilePictureImageView.alpha = alpha
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.setSelected(highlighted, animated: animated)
    }
    
    // MARK: - Content
    
    func updateWithContent(_ inbox: Content) {
        titleLabel.text = inbox.title
        nameLabel.text = "Name label"//inbox.brandName
        
        
        if let img = inbox.pages[0].backgrounds?.file_url, let url = URL(string: img) {
            profilePictureImageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
            
        }
        if let bg = inbox.pages[0].backgrounds?.file_url, let url = URL(string: bg) {
            backgroundImageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
        }
        
        /*
        for item in inbox.pages[0].backgrounds ?? [] {
            if item.order == 0 {
                
                if let url = item.file_url {
                    
                    self.profilePictureImageView?.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
                    
                    self.backgroundImageView?.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
                    
                }
                
            }
        }*/
        
        
        
    }
    
}
