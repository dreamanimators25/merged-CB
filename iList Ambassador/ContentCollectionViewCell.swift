//
//  ContentCollectionViewCell.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 10/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
protocol ContentCollectionViewCellDelegate {
    func didScrollToContentPage(contentPage: ContentPage, atIndex index: Int, withTotalNumberOfPages numOfPages: Int)
}

class ContentCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    static let cellIdentifier = "ContentCollectionViewCell"
    
    var delegate: ContentCollectionViewCellDelegate?
    var ambassadorshipContentUseDelegate: AmbassadorshipContentUseProtocol?
    
    var ContentVc: ContentViewController?
    
    // MARK: Data
    var ambassadorshipContent: AmbassadorshipContent?
    var content: Content?
    
    // MARK: Views
    lazy var contentPageCollectionView: ContentPageCollectionView = {
        let pageCollectionViewFlowLayout = ContentPageCollectionViewFlowLayout()
        let collectionView = ContentPageCollectionView(frame: SCREENSIZE, collectionViewLayout: pageCollectionViewFlowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        collectionView.registerClass(ContentPageCollectionViewCell.self, forCellWithReuseIdentifier: ContentPageCollectionViewCell.cellIdentifier)
        return collectionView
    }()
    
    var currentPage: Int = -1
    
    // Used if there is only one background object
    lazy var backgroundMediaView: ContentBackgroundMediaView = {
        let backgroundMediaView = ContentBackgroundMediaView(frame: SCREENSIZE)
        backgroundMediaView.translatesAutoresizingMaskIntoConstraints = false
        backgroundMediaView.clipsToBounds = false
        return backgroundMediaView
    }()
    
    var currentCellBackgroundMediaView: ContentBackgroundMediaView?
    
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
        content = nil
        resetToDefaultState()
    }
    
    private func setup() {
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        contentView.addSubview(backgroundMediaView)
        contentView.addSubview(contentPageCollectionView)

        let views = [
            "backgroundMediaView" : backgroundMediaView,
            "contentPageCollectionView" : contentPageCollectionView
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[backgroundMediaView]|", options: .AlignAllBaseline, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundMediaView]|", options: .AlignAllBaseline, metrics: nil, views: views))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentPageCollectionView]|", options: .AlignAllBaseline, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentPageCollectionView]|", options: .AlignAllBaseline, metrics: nil, views: views))
        resetToDefaultState()
    }
    
    private func resetToDefaultState() {
        contentPageCollectionView.resetToDefaultState()
    }
    
    func zoomBackgroundWithOffset(offset: CGFloat) {
        if let currentCellBackgroundMediaView = currentCellBackgroundMediaView {
            let width = CGRectGetWidth(bounds)
            let scale = (width + 2.0*abs(0.5*offset))/width
            currentCellBackgroundMediaView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, offset, 0)
            currentCellBackgroundMediaView.transform = CGAffineTransformScale(currentCellBackgroundMediaView.transform, scale, scale)
        }
    }
    
    // MARK: - Content
    
    func updateWithAmbassadorContent(ambassador: AmbassadorshipContent) {
        self.ambassadorshipContent = ambassador
        updateWithContent(ambassador.content)
    }
    
    func updateWithContent(content: Content) {
        self.content = content
        contentPageCollectionView.reloadData()
    }
    
    // MARK: - Animations
    
    func didDissappear() {
        contentPageCollectionView.resetToDefaultState()
        // Animate dissappear?
    }
    
    func didAppear() {
        // Animate appear?
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let content = content {
            return content.pages.count // Number of content pages in the content
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ContentPageCollectionViewCell.cellIdentifier, forIndexPath: indexPath) as! ContentPageCollectionViewCell
         cell.delegate = self.ambassadorshipContentUseDelegate
        if let content = content, let ambassadorshipContent = ambassadorshipContent {
            let row = indexPath.item
            let contentPage = content.pages[row]
            cell.updateWithContent(ambassadorshipContent, contentPage: contentPage, contentPageIndex: row)
            if content.backgrounds.count > 0 && content.backgrounds.count > row {
                cell.updateWithContentPageBackground(content.backgrounds[row])
            } else {
                cell.updateWithContentPageBackground(nil) // Makes background transparent
            }
            // Store background media object for easy access for bounce animations
            currentCellBackgroundMediaView = cell.backgroundMediaView
        }
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < 0) {
            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            if let cell = contentPageCollectionView.cellForItemAtIndexPath(indexPath) as? ContentPageCollectionViewCell {
                cell.zoomBackgroundWithOffset(scrollView.contentOffset.y)
            }
        } else if (scrollView.contentOffset.y > (scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds))) {
            if let content = content {
                let indexPath = NSIndexPath(forItem: content.pages.count-1, inSection: 0)
                if let cell = contentPageCollectionView.cellForItemAtIndexPath(indexPath) as? ContentPageCollectionViewCell {
                    cell.zoomBackgroundWithOffset(scrollView.contentOffset.y - (scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds)))
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        handlePageDidUpdateForScrollView(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        handlePageDidUpdateForScrollView(scrollView)
    }
    
    private func handlePageDidUpdateForScrollView(scrollView: UIScrollView) {
        guard let content = content else {
            return
        }
        let numOfPages = contentPageCollectionView.numberOfVerticalPages()
        let currentPage = contentPageCollectionView.currentVerticalPage()
        let contentPage = content.pages[currentPage]
        delegate?.didScrollToContentPage(contentPage, atIndex: currentPage, withTotalNumberOfPages: numOfPages)
    }

}
