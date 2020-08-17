//
//  ActivitiesTableViewCell.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 2017-01-05.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit

class ActivitiesTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "ActivitiesTableViewCell"
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.whiteColor()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8.0
        self.contentView.addSubview(view)
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Font.boldFont(17.0)
        label.textColor = Color.purpleColor()
        self.containerView.addSubview(label)
        return label
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Font.normalFont(15.0)
        label.textColor = Color.darkGrayColor()
        self.containerView.addSubview(label)
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = Font.normalFont(13.0)
        label.textColor = Color.darkGrayColor()
        self.containerView.addSubview(label)
        return label
    }()
    
    lazy var circularImageView: CircularImageView = {
        let imageView = CircularImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.image = UIImage(named: "activity")
        self.contentView.addSubview(imageView)
        return imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        dateLabel.text = nil
        circularImageView.image = UIImage(named: "activity")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectionStyle = UITableViewCell.SelectionStyle.default
        
        containerView.frame = contentView.bounds.insetBy(dx: 32.0, dy: 8.0).offsetBy(dx: 16.0, dy: 0.0)
        
        let labelsContainerFrame = containerView.bounds.insetBy(dx: 32.0, dy: 0.0)
        titleLabel.frame = labelsContainerFrame.divided(atDistance: labelsContainerFrame.height/2.0, from: .minYEdge).slice
        subtitleLabel.frame = labelsContainerFrame
        dateLabel.frame = labelsContainerFrame.divided(atDistance: labelsContainerFrame.height/2.0, from: .minYEdge).remainder
        
        circularImageView.center = CGPoint(x: containerView.frame.minX, y: containerView.frame.midY)
        contentView.bringSubviewToFront(circularImageView)
    }
    
    // MARK: - Selection
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.alpha = highlighted ? 0.6 : 1.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        self.alpha = selected ? 0.6 : 1.0
    }
    
}
