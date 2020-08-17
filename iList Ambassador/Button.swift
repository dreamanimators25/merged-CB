//
//  Button.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 16/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class Button: UIButton {
    
    var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    
    var titleColor: UIColor = UIColor.white {
        didSet {
            setTitleColor(titleColor, for: UIControl.State())
        }
    }
    
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
        backgroundColor = Color.purpleColor()
        titleColor = Color.whiteColor()
        titleLabel?.font = Font.titleFont(FontSize.Large)
        
        layer.cornerRadius = CornerRadius.Default
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicatorView)
        
        addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
    }
    
    // MARK: - Activity indicator
    
    func startLoading() {
        isEnabled = false
        setTitleColor(backgroundColor, for: UIControl.State())
        if !isLoading() {
            activityIndicatorView.startAnimating()
        }
    }
    func isLoading() -> Bool {
        return activityIndicatorView.isAnimating
    }
    func stopLoading() {
        isEnabled = true
        setTitleColor(titleColor, for: UIControl.State())
        if isLoading() {
            activityIndicatorView.stopAnimating()
        }
    }
    
    // MARK: - Setters
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title?.uppercased(), for: state)
    }
}

class BrandButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        imageView?.contentMode = .scaleAspectFill
        layer.cornerRadius = bounds.size.width / 2
        imageView?.clipsToBounds = true
        clipsToBounds = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2
    }
}

class BounchingButton: UIButton {
    lazy var textLabel: ShadowLabel = {
        let label = ShadowLabel(frame: self.frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = Font.semiTitleFont(16)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
       // setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
      //  setup()
    }
    
    fileprivate func setup() {
        addSubview(textLabel)
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        textLabel.text = NSLocalizedString("READ_MORE", comment: "")
        layoutIfNeeded()
        animateBounce(CGPoint(x: 0, y: -4))
    }
    
    func animateBounce(_ offset: CGPoint) {
        //let center = self.center
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.autoreverse, .repeat], animations: {
            self.center = CGPoint(x: self.center.x + offset.x, y: self.center.y + offset.y)
            }, completion: {finished in
                //self.center = center
        })
    }
    
    func stopAnimateBounce() {
        layer.removeAllAnimations()
    }
}
