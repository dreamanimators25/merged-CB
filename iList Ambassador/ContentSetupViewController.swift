//
//  ContentPageViewController.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-07-20.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import Crashlytics
import Alamofire
import AlamofireImage
import AVFoundation
import Social
import UIKit
import Photos
import AVFoundation
import AVKit
import MessageUI
import HCVimeoVideoExtractor
import AVKit

var loadVimeoPlayer : ((_ url:String)-> (Void))?
var actualContents = [Content]()
var loadCollectionView : ((_ index:IndexPath)-> (Void))?

class ContentSetupViewController: UIViewController {
    
    @IBOutlet weak var channelImgView: UIImageView!
    @IBOutlet weak var channelNameLbl: UILabel!
    
    static var ambassadorId: Int?
    
    // MARK: Data
    var ambassadorship: Ambassadorship? {
        didSet {
            if let ambassadorship = ambassadorship {
                ContentSetupViewController.ambassadorId = ambassadorship.id
                updateContentWithId(ambassadorship.id)
            }
        }
    }
    
    var contentId: Int?
    
    @IBAction func closeButtonPressed(_ sender: BrandButton) {
        closeBrand()
    }
    
    @IBOutlet weak var closeButton: BrandButton! {
        willSet {
            newValue.setImage(UIImage(named: "close11"), for: .normal)
        }
    }
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var contentArray = [Content]()
    var fromInbox = false
    
    var contents: [Content]? {
        didSet {
            if self.fromInbox == false {
                if let contents = contents {
                    print("CONTENT ISEMPTY")
                    print(contents.isEmpty)
                    self.showEmptyState(contents.isEmpty)
                } else {
                    self.showEmptyState(true)
                }
            }
        }
    }
    
    var useContent = 0
    var content: Content? {
        didSet {
            
        }
    }
    
    lazy var outboundShareManager: OutboundShareManager = {
        return OutboundShareManager(presentingViewController: self)
    }()
        
    // MARK: - Views
    @IBOutlet weak var contentCollectionView: UICollectionView!
    @IBOutlet weak var brandButton: BrandButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var exitBrandButton: BrandButton!
    @IBOutlet weak var facebookShareButton: UIButton!
    @IBOutlet weak var twitterShareButton: UIButton!
    @IBOutlet weak var testImageView: UIImageView!
    
    // MARK: - Varibles

    var backgroundForSharing = UIImageView() {
        didSet {
            print("Backgroundimageforsharing has been set")
        }
    }
    
    var user: User? {
        didSet {
            print("USER HAS BEEN SET")
            guard let user = user else { return }
            //updateContentWithContentId(user.id)
        }
        
    }
    
    static var isMulti = false
    var contentCount = 0
    var multiDelegate: MultiPageDelegate?
    var x = 0
    var currentSubPage = 0
    static var currentContent = 0
    static var currentPage: Int = 0
    var contentShareId = 0
    var contentBackground: UIImageView?
    var shareImage: UIImage?
    
    var backgroundURL: String? {
        didSet {
            print(backgroundURL)
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        
//        self.navigationController?.popViewController(animated: true)
        closeBrand()
    }
    
    //let name = Notification.Name(rawValue: showShareButtonNotificationKey)
    
    // MARK: - Statistics
    var statistics: AmbassadorStatistic?
    var statsTimer = Timer()
    var startTime = TimeInterval()
    var secondsOnPage: Int = 0
    var clicksOnPage: Int = 0
    
    
    static func updateMulti() {
        isMulti = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.channelNameLbl.text = self.ambassadorship?.brand.name ?? ""
        
        if let file = self.ambassadorship?.brand.logotypeUrl {
            if let url = URL(string: file) {
                channelImgView.af_setImage(withURL: url)
            }
        }
        
        
        
        //        if UIDevice.current.screenType != UIDevice.ScreenType.iPhoneX {
        //            topConstraint.constant = -20
        //        }
        
        //exitBrandButton.backgroundColor = .red
        
        loadVimeoPlayer = { vimURL in
            self.showVimeoPlayer(vimURL)
        }
        
        
        loadCollectionView = { ind in
            //self.contentCollectionView.reloadItems(at: [ind])
            self.contentCollectionView.reloadData()
            
            self.contentCollectionView.scrollToItem(at: IndexPath.init(row: ind.row, section: ind.section), at: [.centeredHorizontally,.centeredVertically], animated: false)
        }
    }
    
    func makeBarButton()
    {
        self.makeNavigationBar()
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
        
        
        let rightbutton = UIButton.init(type: .custom)
        //rightbutton.setImage(UIImage(named: "logo_small")?.withRenderingMode(.alwaysOriginal), for: .normal) //Sameer 1/5/2020
        rightbutton.setImage(UIImage(named: "home")?.withRenderingMode(.alwaysOriginal), for: .normal)
        rightbutton.addTarget(self, action: #selector(rightBarTapped(_:)), for: .touchUpInside)
        //rightbutton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        //rightbutton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        //let rightbarButton = UIBarButtonItem(customView: rightbutton)
        //self.navigationItem.rightBarButtonItem = rightbarButton
        rightbutton.frame = CGRect.init(x: 44, y: 0, width: 32, height: 32)
        
        
        
        let rightbutton1 = UIButton.init(type: .custom)
        rightbutton1.setImage(UIImage(named: "home")?.withRenderingMode(.alwaysOriginal), for: .normal)
        rightbutton1.addTarget(self, action: #selector(rightBar1Tapped(_:)), for: .touchUpInside)
        //rightbutton1.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        //rightbutton1.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        //let rightbarButton1 = UIBarButtonItem(customView: rightbutton1)
        //self.navigationItem.rightBarButtonItem = rightbarButton1
        rightbutton1.frame = CGRect.init(x: 0, y: 0, width: 32, height: 32)
        
        
        let btnView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 76, height: 32))
        btnView.addSubview(rightbutton)
        //btnView.addSubview(rightbutton1) //Sameer 1/5/2020
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btnView)
        
        
        //let rightbutton = UIBarButtonItem.init(image: UIImage.init(named: "logo_small"), style: .done, target: self, action: #selector(rightBarTapped(_:)))
        //let rightbutton1 = UIBarButtonItem.init(image: UIImage.init(named: "up"), style: .plain, target: self, action: #selector(rightBar1Tapped(_:)))
        //self.navigationItem.rightBarButtonItems = [rightbutton,rightbutton1]
        
    }
    
    @objc func closeButtonTapped(_ sender: AnyObject?) {
        if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsTableViewController") as? SettingsTableViewController {
            vc.user = user
            vc.isMenu = true
            
            let transition = CATransition()
            transition.duration = 0.4
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(vc, animated: true)
            //present(vc, animated: false, completion: nil)
        }
    }
    
    @objc func rightBarTapped(_ sender: AnyObject?) {
         self.onClose(sender)
    }
    
    @objc func rightBar1Tapped(_ sender: AnyObject?) {
       self.contentCollectionView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: [.centeredHorizontally,.centeredVertically], animated: false)
    }
    
    override func viewDidLayoutSubviews() {
//        self.contentCollectionView.frame = self.view.bounds
//        if #available(iOS 11.0, *) {
//            contentCollectionView?.contentInsetAdjustmentBehavior = .never
//
//        }
//
//        self.scrollViewDidScroll(self.contentCollectionView)

    }
    
    func shareFacebook(_ imageView: UIImageView, isBack: Bool, page: Int) {
        /* August-Sameer
        var image = imageView.image
        if let multiCell = contentCollectionView.visibleCells.first as? MultiPage,
            let singleCell = multiCell.multiPageCollectionView.visibleCells.first as? SinglePage {
            if isBack {
                image = singleCell.backgroundImageView?.image
            } else {
               image = singleCell.sharableImageView?.image
            }
        }
        
        if image == nil {
            showMessage("", "Image not loaded yet")
            return
        }

        let post = SLComposeViewController(forServiceType: SLServiceTypeFacebook)!
        post.setInitialText(self.content?.title)
        post.add(image)
        self.present(post, animated: true, completion: nil)
        
//        let vc = TestViewController()
//        vc.im = image
//        self.present(vc, animated: true, completion: nil)
        */
    }
    
   func shareInstagram(_ imageView: UIImageView) {
        generateShareAlert("Instagram", imageView: imageView, platform: "Instagram")
    }
    
    func shareFacebookLink(_ link: String) {
        let post = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        post?.setInitialText(self.content?.title)
        post?.add(URL.init(string: link))
        self.present(post!, animated: true, completion: nil)
    }
    
    func shareTwitterLink(_ link: String) {
        let post = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        post?.setInitialText(self.content?.title)
        post?.add(URL.init(string: link))
        self.present(post!, animated: true, completion: nil)
    }
    
    func shareTwitter(_ imageView: UIImageView, isBack: Bool, page: Int) {
        /* August-Sameer
        var image = imageView.image
        if let multiCell = contentCollectionView.visibleCells.first as? MultiPage,
            let singleCell = multiCell.multiPageCollectionView.visibleCells.first as? SinglePage {
            if isBack {
                image = singleCell.backgroundImageView?.image
            } else {
                image = singleCell.sharableImageView?.image
            }
        }
        
        if image == nil {
            showMessage("", "Image not loaded yet")
            return
        }
        
        let post = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        post?.setInitialText(self.content?.title)
        post?.add(image)
        self.present(post!, animated: true, completion: nil)
        
//        let vc = TestViewController()
//        vc.im = image
//        self.present(vc, animated: true, completion: nil)
        */
    }
    
    func generateShareAlert(_ title: String, imageView: UIImageView, platform: String) {
        let activityVC = UIActivityViewController(activityItems: [imageView.image as Any], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.excludedActivityTypes = [
            UIActivity.ActivityType.airDrop, UIActivity.ActivityType.mail, UIActivity.ActivityType.message,
            UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToTwitter, UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print, UIActivity.ActivityType.saveToCameraRoll
        ]
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.brandButton.isHidden = true
        
        //Sameer 15/6/2020
//        loadStatistics = {
//            self.endStats()
//        }
        
        self.makeBarButton()
        NotificationCenter.default.post(name: Notification.Name.init("showMenu"), object: nil, userInfo: ["data" : true])
        //super.view.layoutSubviews()
//        let player = AVPlayer(url: URL(string: "https://ilistambassador.s3.amazonaws.com:443/dev/content/backgrounds/709c56e1-7d25-4d5f-92ee-097fe67f5dbe.mp4")!)
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//        self.present(playerViewController, animated: true) {
//            playerViewController.player!.play()
//        }
        
        if #available(iOS 11.0, *) {
            contentCollectionView?.contentInsetAdjustmentBehavior = .never
        }
        
        exitBrandButton.imageView?.contentMode = .scaleAspectFit

//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(closeBrand),
//                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
//                                               object: nil)
        
        emptyStateLabel.text = NSLocalizedString("NO_CONTENT_AVAILABLE", comment: "")
        self.contentCollectionView.reloadData()
        print("Whatevs man")
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        self.contentCollectionView.setNeedsLayout()
//        self.contentCollectionView.layoutIfNeeded()
//    }

    // MARK: - Empty state
    
    fileprivate func showEmptyState(_ show: Bool) {
        guard let label = emptyStateLabel else { return }
        emptyStateLabel.isHidden = !show
    }

    // MARK: Actions
    func showAlertOnCell(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default) { action in
            
        }
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    func showAlertForIndexOnCell(_ title: String, message: String, alertButtonTitles: [String], alertButtonStyles: [UIAlertAction.Style], vc: UIViewController, completion: @escaping (Int)->Void) -> Void
    {
        let alert = UIAlertController(title: title,message: message,preferredStyle: UIAlertController.Style.alert)
        
        for title in alertButtonTitles {
            let actionObj = UIAlertAction(title: title,style: alertButtonStyles[alertButtonTitles.firstIndex(of: title)!], handler: { action in
                completion(alertButtonTitles.firstIndex(of: action.title!)!)
            })
            
            alert.addAction(actionObj)
        }
        
        //alert.view.tintColor = Utility.themeColor
        
        //vc will be the view controller on which you will present your alert as you cannot use self because this method is static.
        //vc.present(alert, animated: true, completion: nil)
        present(alert, animated: true, completion: nil)
        
        //UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func presentUseAlert(_ title: String, _ message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let ok = UIAlertAction(title: "OK", style: .default) { action in
            
            switch title {
            case "Information":
                print("Placeholder for activating information function")
            case "Use":
                print("Placeholder for activating Use functionality")
            case "Follow link":
                print("Placeholder for activating follow link functionality")
            case "Use the code below":
                print("Placeholder for activating using code functionality")
            case "Would you like to become an affiliate":
                print("Placeholder for becoming an afiliate functionality")
            case "Open PDF Document":
                print("Placehold for opening a PDF document placeholder")
            default:
                break
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @IBAction func exitBrand(_ sender: BrandButton) {
        closeBrand()
    }
    
    func closeBrand() {
        /* August-Sameer
        let cells = contentCollectionView.visibleCells
        for cell in cells {
            if let cell = cell as? SinglePage {
                cell.pauseMedia()
            } else if let cell = cell as? MultiPage {
                cell.reset()
            }
        }*/
        
        let cells = contentCollectionView.visibleCells
        
        for cell in cells {
            if let cell = cell as? MultiPageCVCell {
                cell.closeCell = false
                cell.reset()
            }
        }
        
        //self.endStats()
//        NotificationCenter.default.removeObserver(NSNotification.Name.UIApplicationDidEnterBackground)
        endStats() //Sameer 29/4/2020
        dismiss(animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        scrollContent(-1)
    }
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        scrollContent(1)
    }
    
    func scrollContent(_ direction: Int) {
        contentCollectionView.scrollHorizontal(ContentSetupViewController.currentContent + direction, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showShareSegue" {
            let navVC = segue.destination as! UINavigationController
            if let vc = navVC.viewControllers.first as? ShareContentViewController {
                vc.contentShareId = self.contentShareId
            }
        } else if segue.identifier == "showShareOutboundSegue" {
            let navVC = segue.destination as! UINavigationController
            if let vc = navVC.viewControllers.first as? ShareContentViewController {
                vc.contentShareId = self.contentShareId
                vc.performOutboutShareOnAppear = true
            }
        }
    }
    
    func setBrandImg(_ imgString: String) {
        Alamofire.request(imgString).responseImage { response in
            if let image = response.result.value {
                if let button = self.brandButton {
                    button.setImage(image, for: .normal)
                }
            }
        }
    }

    // MARK: - Content
    
    func updateContentWithId(_ id: Int) {
        ContentManager.sharedInstance.getContentForId(id) { (contents, error) in
            if let contents = contents {
                self.contentArray += contents
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self.updateContentWithContentId((self.user?.id)!)
                })
                //self.updateContentWithContentId((self.user?.id)!)
                print("Added contents from channel to array")
                DispatchQueue.main.async(execute: {
                    guard let view = self.contentCollectionView else { return }
                    
                    self.setupStatistics(contents)
                    self.handleContentButtons()
                    //self.contentCollectionView.reloadData()
                    
                    self.shareButtons(self.contentCollectionView.currentHorizontalPage(), 0)
                })
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        }
    }
    
    func updateContentWithContentId(_ id: Int) {
        ContentManager.sharedInstance.getSharedContent(id, completion: {contents, error in
            if let contents = contents {
                
                self.contentArray += contents
                self.contents = self.contentArray
                
                actualContents = self.contentArray
                
                print("Just added contents from other user to array")
                DispatchQueue.main.async(execute: {
                    guard let view = self.contentCollectionView else { return }
                    
                    //self.setupStatistics(contents) //Sameer 16/6/2020
                    self.setupStatistics(self.contents ?? [])
                    self.handleContentButtons()
                    self.contentCollectionView.reloadData()
                    
                    self.contentCollectionView.performBatchUpdates({
                        print("Loaded done")
                    }, completion: { (bool) in
                        
                        if isComeFromPush {
                            
                            if let indx = self.contents?.firstIndex(where: { $0.id == contentIdPush }) {
                                self.contentCollectionView.scrollToItem(at: IndexPath.init(row: indx, section: 0), at: [.centeredHorizontally,.centeredVertically], animated: false)
                                isComeFromPush = false
                            }
                            
                            /*
                             if let indx = self.contents?.index(where: { $0.id == contentIdPush }) {
                             self.contentCollectionView.scrollToItem(at: IndexPath.init(row: 0, section: indx), at: [.centeredHorizontally,.centeredVertically], animated: false)
                             }*/
                            
                        }
                        
                    })
                    
                })
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        })
    }
    
    // MARK: - Statistics
    
    func setupStatistics(_ contents: [Content]) {
        backgroundThread(0.0, background: {
            var contentIds = [Int]()
            var pageIds = [Int:[Int]]()
            var i = 0
            for content in contents {
                contentIds.append(content.id)
                var ids = [Int]()
                for page in content.pages {
                    ids.append(page.id)
                }
                pageIds[i] = ids
                i += 1
            }
            var statId = 0
            if let id = self.contentId {
                statId = id
            } else if let ambassadorship = self.ambassadorship {
                statId = ambassadorship.id
            }
            self.statistics = AmbassadorStatistic(id: statId, contentIds: contentIds, pageIds: pageIds)
            }, completion: {
                self.resetTimer()
                self.startTimer()
        })
    }
    
    func resetTimer() {
        statsTimer.invalidate()
    }
    
    func startTimer() {
        if !statsTimer.isValid {
            statsTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            startTime = Date.timeIntervalSinceReferenceDate
        }
    }
    
    @objc func updateTime() {
        let currentTime = Date.timeIntervalSinceReferenceDate
        var elapsedTime: TimeInterval = currentTime - startTime
        let minutes = round(elapsedTime / 60.0)
        
        elapsedTime -= (TimeInterval(minutes) * 60)
        let seconds = round(elapsedTime)
        
        secondsOnPage = Int(seconds)
    }
    
    func endStats() {
        if let statis = statistics {
            statis.addPageDuration(ContentSetupViewController.currentContent, page: ContentSetupViewController.currentPage, seconds: secondsOnPage)
            StatisticsManager.sharedInstance.sendAmbassadorStatistics(statis, completion: { success, error in
                 debugPrint("Error: \(String(describing: error))")
            })
        }
    }
    
    func addClickCount() {
        if let stats = statistics {
            stats.addPageClicks(ContentSetupViewController.currentContent, page: ContentSetupViewController.currentPage, clicks: 1)
        }
    }
    
    func addDuration() {
        resetTimer()
        if let stats = statistics {
            stats.addPageDuration(ContentSetupViewController.currentContent, page: ContentSetupViewController.currentPage, seconds: secondsOnPage)
        }
        startTimer()
    }
}

extension ContentSetupViewController: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if useContent == 0 {
            if let contents = contents {
                return contents.count
            }
        } else if useContent == 1 {
            return 1
        }
        return 0
    }
    
    /* August-Sameer
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiPageCell", for: indexPath) as! MultiPage
        print("index path = \(indexPath)")
        
        if useContent == 0 {
            if let contents = contents {
                let content = contents[indexPath.row]
                
                cell.collection = contentCollectionView
                cell.content = content
                cell.delegatePaser = self
                cell.delegate = self
            }
        } else if useContent == 1 {
            if let content = content {
                let content = content
                cell.collection = contentCollectionView
                cell.shareButton.imageView?.contentMode = .scaleAspectFit
                cell.content = content
                cell.delegatePaser = self
                cell.delegate = self
            }
        }
        
        return cell
     }*/
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let multiPageCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiPageCVCell", for: indexPath) as! MultiPageCVCell
        
        //let content = contents?[indexPath.row]
        //multiPageCVCell.content = content
        //multiPageCVCell.delegate = self
        
        return multiPageCVCell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? MultiPageCVCell {
            let content = contents?[indexPath.row]
            cell.content = content
            cell.delegate = self
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        /* August-Sameer
        if let cell = cell as? MultiPage {
            cell.reset()
        }*/
        
        if let cell = cell as? MultiPageCVCell {
            cell.reset()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.contentCollectionView.bounds.width, height: self.contentCollectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension ContentSetupViewController: MultiPageDelegate {
    
    func showPageContentData(header: ContentPageComponent, body: ContentPageComponent, background: ContentPageBackground, currPage currpage: Int,cont:Content) {
        
        let cells = contentCollectionView.visibleCells
        for cell in cells {
            if let cell = cell as? MultiPageCVCell {
                //cell.reset()
                cell.pauseCells()
            }
        }
        
        let vc = UIStoryboard(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "ShowContentVC") as! ShowContentVC
        vc.content = cont
        vc.currentPage = currpage
        vc.component0 = header
        vc.component1 = body
        vc.background = background
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openLinkInAppInWebView(link: String) {
    
    }
    
    func openEmailLink(link: String) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([link])
            
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            let coded = "mailto:\(link)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            /*
            if let emailURL = coded
            {
                self.openLinkInAppInWebView(link: emailURL)
            }*/
            
            if let emailURL = URL(string: coded!)
            {
                if UIApplication.shared.canOpenURL(emailURL)
                {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(emailURL, options: [:], completionHandler: { (result) in
                            if !result {
                                // show some Toast or error alert
                                //("Your device is not currently configured to send mail.")
                            }
                        })
                    } else {
                        UIApplication.shared.openURL(emailURL)
                        // Fallback on earlier versions
                    }
                }
            }
            
        }
    }
    
    func showContentViewController(_ amb: Ambassadorship) {
       // let user = UserManager.sharedInstance.user
        
        let contentViewController = UIStoryboard(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "ContentController") as! ContentSetupViewController
        contentViewController.ambassadorship = amb
        contentViewController.user = user
        
        self.navigationController?.pushViewController(contentViewController, animated: true)
    }
    
    func showGift(_ title: String, mess: String?, res: @escaping (Bool) -> ()) {
        let alertController = UIAlertController(title: title, message: mess, preferredStyle: UIAlertController.Style.actionSheet)
        
        alertController.addAction(UIAlertAction(title:  "Yes", style: UIAlertAction.Style.destructive, handler: { (alertAction: UIAlertAction) in
            res(true)
        }))
        
        alertController.addAction(UIAlertAction(title:  "No", style: UIAlertAction.Style.cancel, handler: { (alertAction: UIAlertAction) in
            res(false)
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }

    func showMessage(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showDialog(_ message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func currentSubPage(_ page: Int) {
        currentSubPage = page
        print("curr sub page = \(currentSubPage)")
    }

    func currentPage(_ page: Int) {
        addDuration()
        print("curr page = \(ContentSetupViewController.currentPage)")
        ContentSetupViewController.currentPage = page
    }
    
    func shareContent(_ id: Int) {
        //showShare(id)
    }
    
    func shareContentOutbound(_ id: Int) {
        //showShareOutbound(id)
    }
    
    func vertical(_ verticalPage: Int) {
        
    }
    
    func retrieveImage(_ url: String) {
        Alamofire.request(url).downloadProgress(closure: { (Progress) in
            print(Progress.fractionCompleted)
        }).responseData { (response) in
            print(response.result)
            print(response.result.value)
            
            if let image = response.result.value {
                self.testImageView.image = UIImage(data: image)
            }
        }
    }
    
    // TODO: Put this functionality in MultiPage, once done remove notifications. handleContentButtons func must switch delegate
    
    func shareButtons(_ contentNumber: Int?, _ subPageNumber: Int?) {
        
    }
 
}

extension ContentSetupViewController : UIScrollViewDelegate {
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        selectedRaw = nil
        selectedSection = nil
        
        if let cells = self.contentCollectionView.visibleCells as? [MultiPageCVCell] {
            for cell in cells {
                cell.reset()
            }
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var scrollOffset = scrollView.contentOffset.x
        let contentWidht = contentCollectionView.contentSize.width - contentCollectionView.frame.size.width
        
        var indexPath:IndexPath?
        //print("Cell indexPath is:-\(indexPath.row)")
        
        if scrollOffset < 0 {
            indexPath = IndexPath(row: 0, section: 0)
        } else if scrollOffset > contentWidht {
            indexPath = IndexPath(row: contentCollectionView.numberOfHorizontalPages()-1, section: 0)
            print("Cell indexPath is:-\(indexPath?.row ?? 0)")
            scrollOffset = scrollOffset - contentWidht
        }
        if let indexPath = indexPath {
            if let cell = contentCollectionView.cellForItem(at: indexPath) as? MultiPageCVCell {
                cell.zoomBackground(scrollOffset, y: 0)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        calculateCurrentContentNumber()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        calculateCurrentContentNumber()
    }
    
    func calculateCurrentContentNumber() {
        addDuration()
        handleContentButtons()
    }
    
    func handleContentButtons() {
        guard let scroll = contentCollectionView else { return }
        
        ContentSetupViewController.currentContent = scroll.currentHorizontalPage()
        print("curr = \(ContentSetupViewController.currentContent)")
        
        shareButtons(ContentSetupViewController.currentContent, 0)
        if let contents = contents, !contents.isEmpty {
            leftButton.isHidden = ContentSetupViewController.currentContent == 0
            rightButton.isHidden = contents.count - 1 == ContentSetupViewController.currentContent
        } else {
            leftButton.isHidden = true
            rightButton.isHidden = true
        }
    }
    
}

extension ContentSetupViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func showVimeoPlayer(_ link: String) {
        
        let linkUrl = URL.init(string: link)
        
        HCVimeoVideoExtractor.fetchVideoURLFrom(url: linkUrl!, completion: { ( video:HCVimeoVideo?, error:Error?) -> Void in
            
            if let err = error {
                print("Error = \(err.localizedDescription)")
                return
            }
            
            guard let vid = video else {
                print("Invalid video object")
                return
            }
                        
            var vidUrl : HCVimeoVideoQuality!
            for item in vid.videoURL {
                vidUrl = item.key
            }
                        
            if let videoURL = vid.videoURL[vidUrl] {
                
                let player = AVPlayer(url: videoURL)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.present(playerController, animated: true) {
                    player.play()
                }
                
            }
        })
    }
}

/* August-Sameer
extension ContentSetupViewController: SinglePageDelegate {
    
    func imageLoaded(image: UIImage) {
        
    }
    
    func showNewLink(link: String) {
        if MFMailComposeViewController.canSendMail() {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([link])
    
        self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            let coded = "mailto:\(link)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let emailURL = URL(string: coded!)
            {
                if UIApplication.shared.canOpenURL(emailURL)
                {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(emailURL, options: [:], completionHandler: { (result) in
                            if !result {
                                // show some Toast or error alert
                                //("Your device is not currently configured to send mail.")
                            }
                        })
                    } else {
                        UIApplication.shared.openURL(emailURL)
                        // Fallback on earlier versions
                    }
                }
            }
        }
    }
    
    func getBackgroundForSharing(_ image: ContentFillImage) {
        //self.backgroundForSharing = image
        //print("ContentSetupView now has the background image")
    }
    
    //S
    func showVimeoPlayer(_ link: String) {
        
        //let url = URL(string: "https://player.vimeo.com/281116099")!
        let linkUrl = URL.init(string: link)
        
        HCVimeoVideoExtractor.fetchVideoURLFrom(url: linkUrl!, completion: { ( video:HCVimeoVideo?, error:Error?) -> Void in
            
            if let err = error {
                print("Error = \(err.localizedDescription)")
                return
            }
            
            guard let vid = video else {
                print("Invalid video object")
                return
            }
            
            //print("Title = \(vid.title), url = \(vid.videoURL), thumbnail = \(vid.thumbnailURL)")
            
            var vidUrl : HCVimeoVideoQuality!
            for item in vid.videoURL {
                vidUrl = item.key
            }
            
            //print(vidUrl)
            
            if let videoURL = vid.videoURL[vidUrl] {
                
                let player = AVPlayer(url: videoURL)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.present(playerController, animated: true) {
                    player.play()
                }
                
            }
        })
    }
    
    func showLink(_ link: String, contentId: Int) {
        addClickCount()
        let webViewController = WebViewController(link: link, contentId: contentId)
        present(webViewController, animated: true, completion: nil)
    }
    
    func showCode(_ code: String, asQR: Bool) {
        addClickCount()
        let contentConsumeInfoViewController = ContentConsumeInfoViewController(code: code, showAsQR: asQR)
        present(contentConsumeInfoViewController, animated: true, completion: nil)
    }
    
    func showContentConsumedWithAmbassadorshipContent(_ contentTitle: String) {
        addClickCount()
        let message = String(format: NSLocalizedString("CONTENT_HAS_BEEN_USED", comment: ""), contentTitle)
        let contentConsumeInfoViewController = ContentConsumeInfoViewController(message: message)
        present(contentConsumeInfoViewController, animated: true, completion: nil)
    }
    
    func showShare(_ contentId: Int) {
        addClickCount()
        contentShareId = contentId
        performSegue(withIdentifier: "showShareSegue", sender: nil)
    }
    
    func showShareOutbound(_ contentId: Int) {
        addClickCount()
        contentShareId = contentId
        print("SHOWING OUTBOUND SHARE")
        outboundShareManager.shareOutbound(withContentId: contentShareId)
    }
    
    func showErrorMessage(_ message: String) {
        let contentConsumeInfoViewController = ContentConsumeInfoViewController(message: message)
        present(contentConsumeInfoViewController, animated: true, completion: nil)
    }
}*/

class ContentCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        if SCREENSIZE.height >= 812
        {
            itemSize = CGSize(width: SCREENSIZE.width, height: SCREENSIZE.height - 88)
        }else{
            itemSize = CGSize(width: SCREENSIZE.width, height: SCREENSIZE.height - 64)
        }
        
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0.0
        sectionInset = UIEdgeInsets.zero

    }
}

protocol ContentView {
    var view: UIView {get}
    var topMarginPercent: CGFloat {get set}
    var horizontalMarginPercent: CGFloat {get set}
    var bottomMarginPercent: CGFloat {get set}
    var marginEdgePercentage: CGFloat {get set}
    var height: CGFloat {get}
    var width: CGFloat {get}
    
    func prepareForReuse()
}
