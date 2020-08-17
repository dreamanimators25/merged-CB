//
//  BackgroundImageView.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 15/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Alamofire

protocol ImageUrlProtocol {
    func setDefaultImageForUser(_ user: User)
    func setImageFromUrl(_ url: URL)
    func prepareForReuse()
}

class BackgroundImageView: UIImageView, ImageUrlProtocol {
    
    var overlayViewAlpha: CGFloat = 0.9 {
        didSet {
            overlayView.backgroundColor = UIColor(white: 0.0, alpha: overlayViewAlpha)
        }
    }
    
    fileprivate var overlayView: UIView = {
        let overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        return overlayView
    }()
    
    // MARK: - View life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        backgroundColor = Color.backgroundColorDark()
        
        
        /*addSubview(overlayView)
        let views = ["overlayView":overlayView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[overlayView]|", options: .alignAllLastBaseline, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[overlayView]|", options: .alignAllLastBaseline, metrics: nil, views: views))
         */
    }
    
    func setBackgroundForUser(_ user: User) {
        if let backgroundImageString = user.profileBackgroundImage, let backgroundImageUrl = URL(string: backgroundImageString) {
            setImageFromUrl(backgroundImageUrl)
        } else {
            setDefaultImageForUser(user)
        }
    }
    
    // MARK: - ImageUrlProtocol
    
    func setDefaultImageForUser(_ user: User) {
        af_cancelImageRequest()
        image = UIImage(named: "default_user_background")
    }
    
    func setImageFromUrl(_ url: URL) {
        af_setImage(withURL: url)
    }
    
    func prepareForReuse() {
        af_cancelImageRequest()
        image = nil
    }

}
