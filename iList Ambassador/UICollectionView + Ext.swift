//
//  UICollectionView + Ext.swift
//  iList Ambassador
//
//  Created by IdeaSoft on 7/4/19.
//  Copyright © 2019 iList AB. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    func reloadDataForConstraints() {
        reloadData()
        invalidateIntrinsicContentSize()
        layoutIfNeeded()
    }
}
