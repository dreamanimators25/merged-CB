//
//  SearchBar.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 20/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class SearchBar: UISearchBar {

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
        
    }

}
