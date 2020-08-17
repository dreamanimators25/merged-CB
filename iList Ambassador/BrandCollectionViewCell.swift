//
//  BrandCollectionViewCell.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 10/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

protocol BrandCollectionViewCellDelegate {
    func didTapDelete(forCell cell: BrandCollectionViewCell)
}


class BrandCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "BrandCollectionViewCell"
    
    var delegate: BrandCollectionViewCellDelegate?
    
    // MARK: Views
    
    lazy var logotypeImageView: ProfilePictureImageView = {
        let imageView = ProfilePictureImageView(frame: CGRect.zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var deleteButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.setImage(UIImage(named:"delete"), for: UIControl.State())
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(deleteButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    var verticalDeleteConstraint:[NSLayoutConstraint]?
    var horizontalDeleteConstraint:[NSLayoutConstraint]?
    
    var canWiggle = true
    
    // MARK: - View life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        logotypeImageView.prepareForReuse()
    }
    
    fileprivate func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = UIColor.clear
        
        contentView.addSubview(logotypeImageView)
        
        let views = ["logotypeImageView" : logotypeImageView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[logotypeImageView]|", options: .alignAllLastBaseline, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[logotypeImageView]|", options: .alignAllLastBaseline, metrics: nil, views: views))
    }
    
    func setAddStyle() {
        canWiggle = false
        logotypeImageView.af_cancelImageRequest()
        logotypeImageView.image = #imageLiteral(resourceName: "add-friend")
        logotypeImageView.backgroundColor = UIColor.clear
    }

    // MARK: - Delete button
    
    func setUpButton() {
        canWiggle = true
        if !contentView.subviews.contains(deleteButton) {
            contentView.addSubview(deleteButton)
        }
        if let verticalDeleteConstraint = verticalDeleteConstraint, let horizontalDeleteConstraint = horizontalDeleteConstraint {
            contentView.removeConstraints(verticalDeleteConstraint)
            contentView.removeConstraints(horizontalDeleteConstraint)
        }
        let views = ["button" : deleteButton]
        
        var buttonHeight:Float = 44.0
        if let img = UIImage(named:"delete") {
            buttonHeight = Float(img.size.width * img.scale)
        }
        let height = Float(frame.size.height)
        let cellD = sqrtf(height * height * 2)
        let d = (cellD - height) / 2
        let spacing = sqrtf((d*d) / 2) - buttonHeight / 2
        
        let metrics = ["size" : "\(buttonHeight)", "spacing": "\(spacing)"]
        
        verticalDeleteConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-spacing-[button(size)]", options: [], metrics: metrics, views: views)
        horizontalDeleteConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-spacing-[button(size)]", options: [], metrics: metrics, views: views)
        
        contentView.addConstraints(verticalDeleteConstraint!)
        contentView.addConstraints(horizontalDeleteConstraint!)
    }
    
    func wiggleCell(_ row:Int) {
        if canWiggle {
            deleteButton.isHidden = false
            let transformAnim  = CAKeyframeAnimation(keyPath:"transform")
            transformAnim.values  = [NSValue(caTransform3D: CATransform3DMakeRotation(0.04, 0.0, 0.0, 1.0)),NSValue(caTransform3D: CATransform3DMakeRotation(-0.04 , 0, 0, 1))]
            transformAnim.autoreverses = true
            transformAnim.duration = (Double(row).truncatingRemainder(dividingBy: 2)) == 0 ?   0.115 : 0.105
            transformAnim.repeatCount = Float.infinity
            transformAnim.isRemovedOnCompletion = true
            layer.add(transformAnim, forKey: "wiggle-wiggle-baby")
        }
    }
    
    func stopWiggleCell() {
        deleteButton.isHidden = true
        self.layer.removeAllAnimations()
        self.transform = CGAffineTransform.identity
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    @objc func deleteButtonPressed(_ sender: UIButton) {
        delegate?.didTapDelete(forCell: self)
    }
    
    // MARK: - Brand
    
    func updateWithBrand(_ brand: Brand) {
        setUpButton()
        
        if let url = URL(string: brand.logotypeUrl) {
            logotypeImageView.setImageFromUrl(url)
            logotypeImageView.backgroundColor = Color.backgroundColorFadedDark()
        } else {
            //logotypeImageView.image = UIImage(named: "defaultbrand")
            logotypeImageView.backgroundColor = Color.backgroundColorFadedDark()
        }
    }
    
}

