//
//  UICollectionView+Extensions.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 11/06/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func cellForItemAtCenterPoint() -> UICollectionViewCell? {
        if let indexPath = indexPathForItem(at: center), let cell = cellForItem(at: indexPath) {
            return cell
        }
        return nil
    }
    
    func isLastIndexPathInCollectionView(_ indexPath: IndexPath) -> Bool {
        return indexPath.item == numberOfItems(inSection: indexPath.section) - 1
    }
}
