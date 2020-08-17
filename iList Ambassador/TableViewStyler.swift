//
//  TableViewStyler.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 21/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class TableViewStyler {
    
    static let defaultUserCellHeight = CGFloat(70.0)
    
    class func removeSeparatorInsetsForCell(_ cell: UITableViewCell) {
        
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
    }
    
    class func headerViewWithWitdth(_ width: CGFloat, height: CGFloat, text: String) -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        headerView.backgroundColor = UIColor.clear
        
        let label = Label()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.font = Font.titleFont(FontSize.ExtraLarge)
        label.textColor = Color.lightGrayColor()
        label.textAlignment = .center
        label.text = text
        headerView.addSubview(label)
        
        let views = ["label":label]
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: .alignAllLastBaseline, metrics: nil, views: views))
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: .alignAllLastBaseline, metrics: nil, views: views))
        
        return headerView
    }
    
}
