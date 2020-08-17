//
//  ProfilePictureImageView.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 06/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import AlamofireImage
import FontAwesomeKit

protocol ProfilePictureImageViewDelegate {
    func didTapProfilePictureImageView(_ profilePictureImageView: ProfilePictureImageView)
}

class ProfilePictureImageView: HexagonalImageView, ImageUrlProtocol {

    var delegate: ProfilePictureImageViewDelegate?
    
    var allowSelection: Bool = false {
        didSet {
            isUserInteractionEnabled = allowSelection
        }
    }
    
    var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
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
        backgroundColor = Color.backgroundColorFadedDark()
        contentMode = .scaleAspectFill
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicatorView)
        
        addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
    }
    func setImageForUser(_ user: User) {
        if let profileImageUrlString = user.profileImage, let profileImageUrl = URL(string: profileImageUrlString) {
            setImageFromUrl(profileImageUrl)
        } else {
            setDefaultImageForUser(user)
        }
    }
    func updateImageForUser(_ user: User, image:UIImage, completion: @escaping (String?) -> ()) {
        UserManager.sharedInstance.updateProfilePictureForUser(user, profilePicture: image, completion:{(imageUrl, error) in
            if let url = imageUrl {
                DispatchQueue.main.async(execute: {
                    completion(url)
                })
            } else {
                completion(nil)
            }
        })
    }

    // MARK: - ImageUrlProtocol
    
    func setDefaultImageForUser(_ user: User) {
        af_cancelImageRequest()
        image = user.defaultImage()
        backgroundColor = Color.backgroundColorFadedDark()
    }
    func setImageFromUrl(_ url: URL) {
        af_setImage(withURL: url)
    }
    
    func prepareForReuse() {
        af_cancelImageRequest()
        image = nil
    }
    
    // MARK: - Selection
    
    fileprivate func setHightlighted(_ highlighted: Bool) {
        alpha = highlighted ? 0.9 : 1.0
    }
    
    // MARK: - Activity indicator
    
    func startLoading() {
        if !activityIndicatorView.isAnimating {
            activityIndicatorView.startAnimating()
        }
    }
    
    func stopLoading() {
        if activityIndicatorView.isAnimating {
            activityIndicatorView.stopAnimating()
        }
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if allowSelection {
            setHightlighted(true)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        setHightlighted(false)
        
        if let touchPoint = touches.first?.location(in: self), bounds.contains(touchPoint) {
            delegate?.didTapProfilePictureImageView(self)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        setHightlighted(false)
    }
    
}

class SettingsBGPhoto: ProfilePictureImageView {
    
    func setBackgroundForUser(_ user: User) {
        if let backgroundImageString = user.profileBackgroundImage, let backgroundImageUrl = URL(string: backgroundImageString) {
            setImageFromUrl(backgroundImageUrl)
        } else {
            setDefaultBGImageForUser(user)
        }
    }
    
    // MARK: - ImageUrlProtocol
    
    func setDefaultBGImageForUser(_ user: User) {
        af_cancelImageRequest()
        image = UIImage(named: "background.jpg")
    }
    
    func updateBackgroundImageForUser(_ user: User, image:UIImage, completion: @escaping (String?) -> ()) {
        UserManager.sharedInstance.updateBackgroundPhotoForUser(user, backgroundPhoto: image, completion:{(imageUrl, error) in
            if let url = imageUrl {
                DispatchQueue.main.async(execute: {
                    completion(url)
                })
            } else {
                completion(nil)
            }
        })
    }
}
