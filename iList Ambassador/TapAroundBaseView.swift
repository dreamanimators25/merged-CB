//
//  TapAroundBaseView.swift
//  iList Ambassador
//
//  Created by IdeaSoft on 7/3/19.
//  Copyright © 2019 iList AB. All rights reserved.
//

import UIKit

class TapAroundBaseView: UIView {
    
    //MARK: - Lifecycle -
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupGesture()
    }
    
    //MARK: - Methods -
    fileprivate func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        addGestureRecognizer(tap)
    }
    
    //MARK: - Actions -
    @objc fileprivate func tapAction(_ sender: UITapGestureRecognizer) {
        endEditing(true)
    }
}
