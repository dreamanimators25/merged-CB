//
//  ShareUserTableViewCell.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-08-11.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import AlamofireImage

class ShareUserTableViewCell: UITableViewCell {
    
    var onShareBlock: ((_ cell: ShareUserTableViewCell)->())?

    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shareButton: Button!
    
    var userId: Int?
    var contentId: Int?
    
    var file: String? {
        didSet {
            if let file = file, let url = URL(string:file) {
                profileImageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.crossDissolve(0.2), runImageTransitionIfCached: false, completion: nil)
            }
        }
    }
    var name: String? {
        didSet {
            if let name = name {
                nameLabel.text = name
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = Font.titleFont(FontSize.Large)
        nameLabel.textColor = Color.blueColor()
        shareButton.titleLabel?.font = Font.titleFont(FontSize.Large)
        shareButton.backgroundColor = UIColor.clear
        shareButton.titleColor = Color.darkGrayColor()
        shareButton.activityIndicatorView.style = .gray
        shareButton.setTitle(NSLocalizedString("SHARE", comment: ""), for: UIControl.State())
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func ShareButtonPressed(_ sender: Button) {
        onShareBlock?(self)        
//        if let userId = userId, let contentId = contentId {
//            sender.startLoading()
//            ContentManager.sharedInstance.shareContent(contentId, targetUserId: userId, completion: { [weak self] success, error in
//                sender.stopLoading()
//                if success {
//                    DispatchQueue.main.async(execute: {
//                        self?.shareButton.setTitle(NSLocalizedString("SHARED", comment: ""), for: UIControlState())
//                        self?.shareButton.isEnabled = false
//                    })
//                } else {
//                    DispatchQueue.main.async(execute: {
//                        self?.shareButton.setTitle(NSLocalizedString("SHARE", comment: ""), for: UIControlState())
//                        self?.shareButton.isEnabled = true
//                        self?.onFailedShareBlock?()
//                    })
//                }
//            })
//        }
    }
    
}
