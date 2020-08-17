//
//  ContentViewController.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 10/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import Crashlytics

class ContentViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Data
    var ambassadorship: Ambassadorship?
    var ambassadorshipContents: [AmbassadorshipContent]?
    var ambassadorshipContent: AmbassadorshipContent?
    
    var bounceOffset: CGFloat = 4.0
    
    var latestHorizontalPage: Int = 0
    var latestVerticalPage: Int = 0
    
    var currentHorizontalPage: Int = 0
    var currentVerticalPage: Int = 0

    var statistics: AmbassadorStatistic?
    var statsTimer = NSTimer()
    var startTime = NSTimeInterval()
    var secondsOnPage: Int = 0
    var clicksOnPage: Int = 0
    
    var isInitialLoad = true
    // MARK: Views
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var arrowsIndicatorView: ArrowsIndicatorView!
    @IBOutlet weak var brandImageView: ProfilePictureImageView!
    
    // MARK: - View life cycle
    
    init(ambassadorship: Ambassadorship) {
        // WARNING: Need to init with "ContentViewController" and not nil as nibName, else it will crash in iOS 8.
        super.init(nibName: "ContentViewController", bundle: nil)
        self.ambassadorship = ambassadorship
        //statistics = AmbassadorStatistic(ambassadorId: ambassadorship.id)
        setup()
    }
    
    init(ambassadorshipContent: AmbassadorshipContent) {
        // WARNING: Need to init with "ContentViewController" and not nil as nibName, else it will crash in iOS 8.
        super.init(nibName: "ContentViewController", bundle: nil)
        self.ambassadorshipContent = ambassadorshipContent
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.backgroundColorDark()
        
        collectionView!.registerClass(ContentCollectionViewCell.self, forCellWithReuseIdentifier: ContentCollectionViewCell.cellIdentifier)
        
        arrowsIndicatorView.delegate = self
        arrowsIndicatorView.bottomArrowButton.showLabelWithText(NSLocalizedString("READ_MORE", comment: ""))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContentViewController.contentLoaded(_:)), name:"contentLoaded", object: nil)
        
        updateContent()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let ambassadorshipContents = ambassadorshipContents {
            for ambC in ambassadorshipContents {
                for bg in ambC.content.backgrounds {
                    if let video = bg.video {
                        //video.deallocObservers()
                    }
                }
            }
        }
        
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        // TODO! Send stats shit and stuff lol
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func brandImageViewTapped(sender: AnyObject) {
        resetTimer()
        endStats()
        dismissViewControllerAnimated(true, completion: nil)
    }
    func endStats() {
        if let statis = statistics {
            statis.addPageDuration(currentHorizontalPage, page: currentVerticalPage, seconds: secondsOnPage)
            StatisticsManager.sharedInstance.sendAmbassadorStatistics(statis, completion: { success, error in
                debugPrint(error)
            })
        }
        
    }
    // MARK: - Content
    
    func updateContent() {
        guard let ambassadorship = ambassadorship else {
            debugPrint("ambassadorship not found in ContentViewController")
            return
        }
        ContentManager.sharedInstance.getContentForAmbassadorship(ambassadorship) { (ambassadorshipContents, error) in
            if let ambassadorshipContents = ambassadorshipContents {
                self.ambassadorshipContents = ambassadorshipContents
                dispatch_async(dispatch_get_main_queue(), {
                    var contentIds = [Int]()
                    var pageIds = [Int:[Int]]()
                    var i = 0
                    for ambassadorshipContent in ambassadorshipContents {
                        contentIds.append(ambassadorshipContent.content.id)
                        var ids = [Int]()
                        for page in ambassadorshipContent.content.pages {
                            ids.append(page.id)
                        }
                        pageIds[i] = ids
                        i += 1
                    }

                    self.resetTimer()
                    self.startTimer()
                    self.statistics = AmbassadorStatistic(id: self.ambassadorship!.id, contentIds: contentIds, pageIds: pageIds)
                    self.collectionView.reloadData()
                })

            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        }
    }
    
    
    // MARK: - Timers
    func resetTimer() {
        statsTimer.invalidate()
    }
    func startTimer() {
        if !statsTimer.valid {
            statsTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(ContentViewController.updateTime), userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
    }
    func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime: NSTimeInterval = currentTime - startTime
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        let seconds = UInt8(elapsedTime)
        
        secondsOnPage = Int(seconds)
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let ambassadorshipContents = ambassadorshipContents {
            return ambassadorshipContents.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ContentCollectionViewCell.cellIdentifier, forIndexPath: indexPath) as! ContentCollectionViewCell
        cell.ambassadorshipContentUseDelegate = self
        
        if let ambassadorshipContents = ambassadorshipContents {
            let ambassadorshipContent = ambassadorshipContents[indexPath.item]
            let ambassContent = ambassadorshipContent
            cell.delegate = self
            cell.updateWithAmbassadorContent(ambassContent)
        }
                
        return cell
    }
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        if let cell = cell as? ContentCollectionViewCell {
            cell.didDissappear()
        }
    }
    func contentLoaded(notification: NSNotification) {
        let currentHorizontalPage = collectionView.currentHorizontalPage()
        if currentHorizontalPage != latestHorizontalPage || isInitialLoad {
            isInitialLoad = false
            handleDidScrollToHorizontalPage(currentHorizontalPage, withTotalNumberOfPages: collectionView.numberOfHorizontalPages())
        }
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ContentCollectionViewCell {
            let currentVerticalPage = cell.contentPageCollectionView.currentVerticalPage()
            if currentVerticalPage != latestVerticalPage {
                handleDidScrollToVerticalPage(currentVerticalPage, withTotalNumberOfPages: cell.contentPageCollectionView.numberOfVerticalPages())
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.x < 0) {
            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ContentCollectionViewCell {
                cell.zoomBackgroundWithOffset(scrollView.contentOffset.x)
            }
        } else if (scrollView.contentOffset.x > (scrollView.contentSize.width - CGRectGetWidth(scrollView.bounds))) {
            if let ambassadorshipContents = ambassadorshipContents {
                let indexPath = NSIndexPath(forItem: ambassadorshipContents.count-1, inSection: 0)
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ContentCollectionViewCell {
                    cell.zoomBackgroundWithOffset(scrollView.contentOffset.x - (scrollView.contentSize.width - CGRectGetWidth(scrollView.bounds)))
                }
            }
        }
    }
    
    // When scrolling is performed programatically (e.g. by tapping a next page button)
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        handleDidScrollToHorizontalPage(scrollView.currentHorizontalPage(), withTotalNumberOfPages: scrollView.numberOfHorizontalPages())
    }
    
    // When user has scrolled manually
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        handleDidScrollToHorizontalPage(scrollView.currentHorizontalPage(), withTotalNumberOfPages: scrollView.numberOfHorizontalPages())
    }
    
    private func handleDidScrollToHorizontalPage(page: Int, withTotalNumberOfPages numOfPages: Int) {
        currentHorizontalPage = page
        resetTimer()
        if let stats = statistics {
            stats.addPageDuration(latestHorizontalPage, page: latestVerticalPage, seconds: secondsOnPage)
        }
        startTimer()
        arrowsIndicatorView.leftArrowButton.hidden = (page == 0)
        arrowsIndicatorView.rightArrowButton.hidden = (page == numOfPages-1)
        
        // We need to update vertical arrows for the new horizontal page
        let indexPath = NSIndexPath(forRow: page, inSection: 0)
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ContentCollectionViewCell {
            let verticalPage = cell.contentPageCollectionView.currentVerticalPage()
            let numberOfVerticalPages = cell.contentPageCollectionView.numberOfVerticalPages()
            arrowsIndicatorView.topArrowButton.hidden = (verticalPage == 0)
            arrowsIndicatorView.bottomArrowButton.hidden = (verticalPage == numberOfVerticalPages-1)
            
            if page == 0 {
                // Only show bottom arrow label when at top
                arrowsIndicatorView.bottomArrowButton.setLabelHidden(false)
                arrowsIndicatorView.bottomArrowButton.animateBounce(CGPointMake(0, -bounceOffset))
            } else {
                arrowsIndicatorView.bottomArrowButton.setLabelHidden(true)
                arrowsIndicatorView.bottomArrowButton.stopAnimateBounce()
            }
        }
        latestHorizontalPage = page
    }
    
    private func handleDidScrollToVerticalPage(page: Int, withTotalNumberOfPages numOfPages: Int) {
        currentVerticalPage = page
        resetTimer()
        if let stats = statistics {
            stats.addPageDuration(currentHorizontalPage, page: latestVerticalPage, seconds: secondsOnPage)
        }
        startTimer()
        arrowsIndicatorView.topArrowButton.hidden = (page == 0)
        arrowsIndicatorView.bottomArrowButton.hidden = (page == numOfPages-1)

        if page == 0 {
            // Only show bottom arrow label when at top
            arrowsIndicatorView.bottomArrowButton.setLabelHidden(false)
            arrowsIndicatorView.bottomArrowButton.animateBounce(CGPointMake(0, -bounceOffset))
        } else {
            arrowsIndicatorView.bottomArrowButton.setLabelHidden(true)
            arrowsIndicatorView.bottomArrowButton.stopAnimateBounce()
        }
        latestVerticalPage = page
    }
    
}

extension ContentViewController: AmbassadorshipContentUseProtocol {

    func showLink(link: String, ambassadorshipContent: AmbassadorshipContent) {
        addClickCount()
        let webViewController = WebViewController(link: link, ambassadorshipContentId: ambassadorshipContent.id)
        presentViewController(webViewController, animated: true, completion: nil)
    }
    
    func showCode(code: String, asQR: Bool, ambassadorshipContent: AmbassadorshipContent) {
        addClickCount()
        let contentConsumeInfoViewController = ContentConsumeInfoViewController(code: code, showAsQR: asQR)
        presentViewController(contentConsumeInfoViewController, animated: true, completion: nil)
    }
    
    func showContentConsumedWithAmbassadorshipContent(ambassadorshipContent: AmbassadorshipContent) {
        addClickCount()
        let message = String(format: NSLocalizedString("CONTENT_HAS_BEEN_USED", comment: ""), ambassadorshipContent.content.title)
        let contentConsumeInfoViewController = ContentConsumeInfoViewController(message: message)
        presentViewController(contentConsumeInfoViewController, animated: true, completion: nil)
    }
    
    func showErrorMessage(message: String) {
        let contentConsumeInfoViewController = ContentConsumeInfoViewController(message: message)
        presentViewController(contentConsumeInfoViewController, animated: true, completion: nil)
    }
    
    func addClickCount() {
        if let stats = statistics {
            stats.addPageClicks(currentHorizontalPage, page: currentVerticalPage, clicks: 1)
        }
    }
}

extension ContentViewController: ContentCollectionViewCellDelegate {
    
    func didScrollToContentPage(contentPage: ContentPage, atIndex index: Int, withTotalNumberOfPages numOfPages: Int) {
        handleDidScrollToVerticalPage(index, withTotalNumberOfPages: numOfPages)
    }
    
}

extension ContentViewController: ArrowsIndicatorViewDelegate {
    
    func didTapArrowForArrowsIndicatorView(arrowsIndicatorView: ArrowsIndicatorView, atPosition position: ArrowsIndicatorViewPosition) {
       /* switch position {
        case .Top:
            if let cell = collectionView.cellForItemAtCenterPoint() as? ContentCollectionViewCell {
                let currentVerticalPage = cell.contentPageCollectionView.currentVerticalPage()
                cell.contentPageCollectionView.scrollToVerticalPage(currentVerticalPage-1, animated: true)
            }
        case .Left:
            collectionView.scrollToHorizontalPage(collectionView.currentHorizontalPage()-1, animated: true)
        case .Bottom:
            if let cell = collectionView.cellForItemAtCenterPoint() as? ContentCollectionViewCell {
                let currentVerticalPage = cell.contentPageCollectionView.currentVerticalPage()
                cell.contentPageCollectionView.scrollToVerticalPage(currentVerticalPage+1, animated: true)
            }
        case .Right:
            collectionView.scrollToHorizontalPage(collectionView.currentHorizontalPage()+1, animated: true)
        }*/
    }
}

/*
class ContentCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        scrollDirection = .Horizontal
        
        itemSize = CGSizeMake(SCREENSIZE.width, SCREENSIZE.height)
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0.0
        sectionInset = UIEdgeInsetsZero
    }
}
 */
