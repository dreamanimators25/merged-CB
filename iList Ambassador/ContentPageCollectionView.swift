//
//  ContentViewCollectionView.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 10/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class ContentPageCollectionView: UICollectionView {
    
    // MARK: - View life cycle
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.clearColor()
        
        pagingEnabled = true
    }
    
    func resetToDefaultState() {
        //scrollToVerticalPage(0, animated: false)
        for cell in visibleCells() {
            if let cell = cell as? ContentPageCollectionViewCell {
                cell.resetToDefaultState()
            }
        }
    }
    
}

class ContentPageCollectionViewFlowLayout: UICollectionViewFlowLayout {
        
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        scrollDirection = .Vertical
        
        itemSize = CGSizeMake(SCREENSIZE.width, SCREENSIZE.height)
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0.0
        sectionInset = UIEdgeInsetsZero
    }
    
}