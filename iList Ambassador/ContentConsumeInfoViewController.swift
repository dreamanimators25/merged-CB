//
//  ContentConsumeInfoViewController.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 18/06/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class ContentConsumeInfoViewController: UIViewController {

    // Views
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var qrCodeImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var qrCodeImageViewHeightConstraint: NSLayoutConstraint!
    
    // Data
    var message: String?
    
    var code: String?
    var showAsQR: Bool?
    
    convenience init(message: String) {
        self.init(nibName: "ContentConsumeInfoViewController", bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
        self.message = message
    }
    
    convenience init(code: String, showAsQR: Bool) {
        self.init(nibName: "ContentConsumeInfoViewController", bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
        self.code = code
        self.showAsQR = showAsQR
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
     
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = CornerRadius.Large
        
        
        let titleFont = Font.boldFont(14.0)
        let subtitleFont = Font.normalFont(24.0)
        
        
        let titleColor = Color.textColorDark()
        let subtitleColor = Color.blueColor()
        
        messageLabel.textColor = Color.textColorDark()
        
        if let message = message {
            messageLabel.font = titleFont
            messageLabel.textColor = Color.textColorDark()
            messageLabel.text = message
        } else if let code = code, let showAsQR = showAsQR {
            // TODO: Show code as code or QR
            let attributesTitleString = NSAttributedString(string: NSLocalizedString("YOUR_CODE", comment: "").uppercased() + ":",
                                                           attributes: [
                                                            NSAttributedString.Key.foregroundColor : titleColor,
                                                            NSAttributedString.Key.font : titleFont])
            let attributesSubtitleString = NSAttributedString(string: "\n\n" + code,
                                                           attributes: [
                                                            NSAttributedString.Key.foregroundColor : subtitleColor,
                                                            NSAttributedString.Key.font : subtitleFont])
            if showAsQR {
                let attributedString = NSMutableAttributedString()
                attributedString.append(attributesTitleString)
                messageLabel.attributedText = attributedString
                
                let qrCodeSize = min(SCREENSIZE.width-40.0, 120.0)
                let qrCodeImage = UIImage.qrImageForCode(code, size: qrCodeSize)
                qrCodeImageView.image = qrCodeImage
                qrCodeImageViewHeightConstraint.constant = qrCodeSize
                qrCodeImageViewWidthConstraint.constant = qrCodeSize
                
            } else {
                let attributedString = NSMutableAttributedString()
                attributedString.append(attributesTitleString)
                attributedString.append(attributesSubtitleString)
                messageLabel.attributedText = attributedString
            }
            
        }
    }
    
    // MARK: - Actions

    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
