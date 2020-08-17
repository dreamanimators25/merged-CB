//
//  TableView.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 27/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class TableView: UITableView {
    
    // MARK: - View life cycle
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        backgroundColor = .white

        separatorStyle = .none
        tableFooterView = UIView()
    }
    
}
