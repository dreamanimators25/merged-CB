//
//  RoundCornerView.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-05-14.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class RoundCornerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = CornerRadius.Large
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = CornerRadius.Large
    }
}
