//
//  ArrowsIndicatorView.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 10/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

enum ArrowsIndicatorViewPosition {
    case Top
    case Left
    case Bottom
    case Right
}

protocol ArrowsIndicatorViewDelegate {
    func didTapArrowForArrowsIndicatorView(arrowsIndicatorView: ArrowsIndicatorView, atPosition position: ArrowsIndicatorViewPosition)
}

class ArrowButton: UIButton {
    
    lazy var textLabel: UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Color.whiteColor()
        label.textAlignment = .Center
        label.font = Font.semiTitleFont(16)
        label.hidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init(arrowsIndicatorViewPosition: ArrowsIndicatorViewPosition) {
        self.init(frame: CGRectZero)
        setImageForArrowIndicatorViewPosition(arrowsIndicatorViewPosition)
    }
    
    private func setup() {
        layer.masksToBounds = false
        
        addSubview(textLabel)
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0.0))
    }
    
    private func setImageForArrowIndicatorViewPosition(arrowsIndicatorViewPosition: ArrowsIndicatorViewPosition) {
        switch arrowsIndicatorViewPosition {
        case .Top:
            setImage(UIImage(named: "up"), forState: .Normal)
        case .Left:
            setImage(UIImage(named: "left"), forState: .Normal)
        case .Bottom:
            setImage(UIImage(named: "down"), forState: .Normal)
        case .Right:
            setImage(UIImage(named: "right"), forState: .Normal)
        }
    }
    
    // MARK: - Public methods
    
    func showLabelWithText(text: String) {
        textLabel.hidden = false
        textLabel.text = text
        layoutIfNeeded()
    }
    
    func setLabelHidden(hidden: Bool) {
        textLabel.hidden = hidden
    }
    
    // MARK: - Animation
    
    func animateBounce(offset: CGPoint) {
        let center = self.center
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.Autoreverse, .Repeat, .CurveEaseInOut], animations: {
            self.center = CGPointMake(self.center.x + offset.x, self.center.y + offset.y)
            }, completion: {finished in
                self.center = center
        })
    }
    
    func stopAnimateBounce() {
        layer.removeAllAnimations()
    }
    
}

class ArrowsIndicatorView: UIView {

    final let margin = CGFloat(4.0)
    final let buttonSize:CGFloat = 50.0
    
    var delegate: ArrowsIndicatorViewDelegate?
    
    lazy var topArrowButton: ArrowButton = {
        let button = ArrowButton(arrowsIndicatorViewPosition: .Top)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(topArrowButtonTapped(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var leftArrowButton: ArrowButton = {
        let button = ArrowButton(arrowsIndicatorViewPosition: .Left)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(leftArrowButtonTapped(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var bottomArrowButton: ArrowButton = {
        let button = ArrowButton(arrowsIndicatorViewPosition: .Bottom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(bottomArrowButtonTapped(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var rightArrowButton: ArrowButton = {
        let button = ArrowButton(arrowsIndicatorViewPosition: .Right)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(rightArrowButtonTapped(_:)), forControlEvents: .TouchUpInside)
        return button
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
    
    private func setup() {
        backgroundColor = UIColor.clearColor()
        addSubview(topArrowButton)
        addSubview(leftArrowButton)
        addSubview(rightArrowButton)
        addSubview(bottomArrowButton)
        // Top
        addConstraint(NSLayoutConstraint(item: topArrowButton, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: margin))
        addConstraint(NSLayoutConstraint(item: topArrowButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        setButtonSize(topArrowButton, horizontal: true)

        // Left
        addConstraint(NSLayoutConstraint(item: leftArrowButton, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: margin))
        addConstraint(NSLayoutConstraint(item: leftArrowButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: margin/2))
        setButtonSize(leftArrowButton, horizontal: false)

        // Bottom
        addConstraint(NSLayoutConstraint(item: bottomArrowButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: bottomArrowButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        setButtonSize(bottomArrowButton, horizontal: true)
        
        // Right
        addConstraint(NSLayoutConstraint(item: rightArrowButton, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: -margin))
        addConstraint(NSLayoutConstraint(item: rightArrowButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: margin/2))
        setButtonSize(rightArrowButton, horizontal: false)
        
        layoutIfNeeded()
        
        // Hide all as default
        setAllArrowsHidden(true)
    }
    
    func setButtonSize(button:UIButton, horizontal: Bool) {
        if let imageView = button.imageView, let image = imageView.image {
            let scale = buttonSize / image.size.width
            let newHeight = image.size.height * scale
            addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: .None, attribute: .NotAnAttribute, multiplier: 1, constant: newHeight))
            addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: .None, attribute: .NotAnAttribute, multiplier: 1, constant: buttonSize))
            var inset: UIEdgeInsets?
            inset = horizontal ? UIEdgeInsetsMake(9, 10, 9, 10) : UIEdgeInsetsMake(29, 20, 29, 20)
            if let i = inset {
                button.imageEdgeInsets = i
                button.alpha = 0.7
            }

        }
    }
    
    func prepareForReuse() {
        setAllArrowsHidden(true)
    }
    
    // MARK: - Arrows
    
    func setAllArrowsHidden(hidden: Bool) {
        topArrowButton.hidden = hidden
        leftArrowButton.hidden = hidden
        bottomArrowButton.hidden = hidden
        rightArrowButton.hidden = hidden
    }
    
    func setHorizontalArrowsHidden(hidden: Bool) {
        leftArrowButton.hidden = hidden
        rightArrowButton.hidden = hidden
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        if hitView == self {return nil}
        return hitView
    }
    
    // MARK: - Actions
    
    func topArrowButtonTapped(sender: AnyObject?) {
        delegate?.didTapArrowForArrowsIndicatorView(self, atPosition: .Top)
    }
    
    func leftArrowButtonTapped(sender: AnyObject?) {
        delegate?.didTapArrowForArrowsIndicatorView(self, atPosition: .Left)
    }
    
    func bottomArrowButtonTapped(sender: AnyObject?) {
        delegate?.didTapArrowForArrowsIndicatorView(self, atPosition: .Bottom)
    }
    
    func rightArrowButtonTapped(sender: AnyObject?) {
        delegate?.didTapArrowForArrowsIndicatorView(self, atPosition: .Right)
    }
    
}
