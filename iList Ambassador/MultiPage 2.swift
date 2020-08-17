//
//  MultiPage.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-07-20.
//  Copyright © 2016 iList AB. All rights reserved.
//

protocol MultiPageDelegate {
    func currentSubPage(_ page: Int)
    func currentPage(_ page: Int)
    func shareContent(_ id: Int)
    func shareContentOutbound(_ id: Int)
    func presentUseAlert(_ title: String, _ message: String)
    func showAlertOnCell(_ title: String, _ message: String)
    func showAlertForIndexOnCell(_ title: String, message: String, alertButtonTitles: [String], alertButtonStyles: [UIAlertAction.Style], vc: UIViewController, completion: @escaping (Int)->Void) -> Void
    func shareFacebook(_ imageView: UIImageView, isBack: Bool, page: Int)
    func shareInstagram(_ imageView: UIImageView)
    func shareTwitter(_ imageView: UIImageView, isBack: Bool, page: Int)
    func shareFacebookLink(_ link: String)
    func shareTwitterLink(_ link: String)
    func showDialog(_ message: String)
    func showContentViewController(_ amb: Ambassadorship) 
    func showMessage(_ title: String, _ message: String)
    func showGift(_ title: String, mess: String?, res: @escaping (_ ok: Bool) -> ())
}

protocol backgroundDelegate: class {
    func setShareImage(_ imageView: UIImageView)
}

let showShareButtonNotificationKey = "se.ilist.iList.showShareButton"

import UIKit
import Alamofire
import MessageUI
import AlamofireImage


class MultiPage: UICollectionViewCell, backgroundDelegate {
    
    var arrContentID = [String]()
    var arrPageID = [String]()
    var click = true
    var baseView = UIView()
    var multiLinkBaseView = UIStackView()
    var base1 = UIView()
    var base2 = UIView()
    var base3 = UIView()
    var link1 = String()
    var link2 = String()
    var link3 = String()
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var linkView: UIView!
    @IBOutlet weak var linkImageView: UIImageView!
    
    @IBOutlet weak var goThereBtn: UIButton!
    @IBOutlet weak var downButton: BounchingButton!
    @IBOutlet weak var shareButton: BrandButton!
    @IBOutlet weak var outboundShareButton: BrandButton!
    
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var useButton: UIButton!
    @IBOutlet weak var facebookShareButton: UIButton!
    @IBOutlet weak var twitterShareButton: UIButton!
    @IBOutlet weak var shareImageView: UIImageView!
    
    @IBOutlet weak var multiPageCollectionView: UICollectionView!
    
    
    var collection: UICollectionView?
    var current: Int?
    var currentContentPage: Int?
    let shareKey = Notification.Name(rawValue: showShareButtonNotificationKey)
    var x = 0
    var BG: UIImageView?
    var delegate: MultiPageDelegate?
    var delegatePaser: SinglePageDelegate?
    static var currPage = 0
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    var shareableBody: Bool = false
    var currentPage: Int = 0 {
        didSet {
            delegate?.currentPage(currentPage)
        }
    }
    var currentSubPage: Int = 0 {
        didSet {
            delegate?.currentSubPage(currentSubPage)
        }
    }

    func update() {
         //facebookShareButton.isHidden = false //s.
    }
   
    var content:Content? {
        didSet {
            self.goThereBtn.isHidden = true;
            self.linkView.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer.init(target: self, action: #selector(tap))
            self.linkView.addGestureRecognizer(gesture)
            
            if (content != nil) {

                currentPage = 0;
                var actionImage: UIImage? = nil
                
                switch content?.pages[currentPage].consumeAction {
                case 1:
                    actionImage = UIImage(named: "use3")
                case 2:
                    actionImage = UIImage(named: "link")
                case 3:
                    self.goThereBtn.setTitle("Go There", for: .normal)
                    actionImage = UIImage(named: "code")
                case 4:
                    actionImage = UIImage(named: "connect")
                case 5:
                    actionImage = UIImage(named: "read")
                case 6:
                    actionImage = UIImage(named: "phone")
                case 7:
                    self.goThereBtn.setTitle("Email", for: .normal)
                    actionImage = UIImage(named: "mail")
                case 8:
                    self.goThereBtn.setTitle("View Excel", for: .normal)
                    //actionImage = UIImage(named: "read")
                case 9:
                    print("9")
                case 10:
                    print("10")
                default: break
                }
                
                linkImageView.image = actionImage
                
                useButton.imageView?.contentMode = .scaleAspectFit
                shareButton.imageView?.contentMode = .scaleAspectFit
                facebookShareButton.imageView?.contentMode = .scaleAspectFit
                twitterShareButton.imageView?.contentMode = .scaleAspectFit
                
                var is_shareable = false
                if self.click {
                    is_shareable = content?.pages[multiPageCollectionView.currentVerticalPage()].is_shareable ?? false
                    
                    shareableBody =  (content?.pages[multiPageCollectionView.currentVerticalPage()].isBodyShare) ?? false
                }else {
                    is_shareable = content?.pages[0].is_shareable ?? false
                    shareableBody =  (content?.pages[0].isBodyShare) ?? false
                }
                
                let shareable = content?.shareable
            
                
                
                print("share = \(shareable ?? false), \(shareableBody)")
                
//                let deadlineTime = DispatchTime.now() + .seconds(5)
//                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
//                    print("row content = \(self.content?.pages.count)")
//                    print("row content = \(ContentSetupViewController.currentPage)")
//                }

                if shareableBody {
                    //facebookShareButton.isHidden = false //s.
                    // instagramShareButton.isHidden = false
                    //twitterShareButton.isHidden = false //s.
                    useButton.isHidden = true
                    shareButton.isHidden = true
                    
                } else if shareable! && is_shareable {
                    //facebookShareButton.isHidden = false //s.
                   // instagramShareButton.isHidden = false
                    //twitterShareButton.isHidden = false //s.
                    useButton.isHidden = true
                    shareButton.isHidden = true
                } else if shareable! && !is_shareable {
                    facebookShareButton.isHidden = true
                   // instagramShareButton.isHidden = true
                    twitterShareButton.isHidden = true
                    useButton.isHidden = false
                    //shareButton.isHidden = false //s.
                } else if !shareable! && is_shareable {
                    //facebookShareButton.isHidden = false //s.
                   // instagramShareButton.isHidden = false
                    //twitterShareButton.isHidden = false //s.
                    useButton.isHidden = true
                    shareButton.isHidden = true
                } else if !shareable! && !is_shareable {
                    facebookShareButton.isHidden = true
                    //instagramShareButton.isHidden = true
                    twitterShareButton.isHidden = true
                    useButton.isHidden = true
                    shareButton.isHidden = true
                }
                
                if !linkView.isHidden {
                    leftConstraint.constant = 94
                } else {
                    leftConstraint.constant = 16
                }
        
               // linkView.isHidden = isIdentity ?? true
                
                handlePageButtons(0)
                
                if multiPageCollectionView.dataSource == nil {
                    multiPageCollectionView.delegate = self
                    multiPageCollectionView.dataSource = self
                    
                }
                
                multiPageCollectionView.reloadData()
            }
            print("Initial current subpage says: \(multiPageCollectionView.currentVerticalPage())")
        }
    }
    
    func presentUseAlert(_ title: String, _ message: String) {
        
    }
    
    
    func shareButtons(_ contentNumber: Int?, _ subPageNumber: Int?) {}
    
    
    func reset() {
        if let content = content, content.pages.count > 0 {
            multiPageCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        pauseCells()
    }
    
    func pauseCells() {
        let cells = multiPageCollectionView.visibleCells as! [SinglePage]
        for cell in cells {
            cell.pauseMedia()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
    }
    
    @objc func tap() {
        
        print("testTap = \(currentPage)")
        
        //print("_CONTENT_IDENT_\(content?.pages[currentPage].identity)")
        
        if let idin = content?.pages[currentPage].identity, let action = content?.pages[currentPage].consumeAction {
            
            print("--- IDIN --- \(idin) ----- ACTION ----- \(action)")
            
            switch action {
            
            case 1:
                //print("id = \(ContentSetupViewController.ambassadorId)")
                
                if let id = content?.pages[currentPage].id {
                    UserManager.sharedInstance.useCoupon("\(ContentSetupViewController.ambassadorId!)", pageId: "\(id)") { (count, unlim, error) in
                        //print("test = \(self.content?.pages[self.currentPage].unlim)")
                        let isUnlim = self.content?.pages[self.currentPage].unlim
                        let mess = isUnlim! ? nil : "Number of Uses left: \(count)"
                        
                        if isUnlim! || count > 0 {
                        self.delegate?.showGift("Are you sure you want to use this content?", mess: mess, res: { ok in
                                UserManager.sharedInstance.tryCoupon("\(ContentSetupViewController.ambassadorId!)", pageId: "\(id)", completion: { (count, unlim, error) in
                                    
                                })
                        })
                        } else {
                            self.delegate?.showMessage("No more uses!", "")
                        }
                    }
                }
            case 3:
                delegate?.showMessage("This is your code", idin)
            case 5:
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string : idin)!, options: [:], completionHandler: { (status) in })
                } else {
                    UIApplication.shared.openURL(URL(string : idin)!)
                }
            case 4:
                AmbassadorshipManager.sharedInstance.requestAmbassadorhipWithCode(idin) { (ambassadorship, error, code) in
                    var message = ""
                    print("code = \(code)")
                    
                    if error != nil {
                      message = "Server error"
                    } else if ambassadorship == nil {
                        message = "You are already an ambassador for this brand"
//                        self.presentUseAlert("You are already an ambassador for this brand", "")
                        return
                    } else if code == 200 || code == 201 {
                        let name = ambassadorship?.brand.name == nil ? "" : ambassadorship!.brand.name
                        message = "You have successfully connected to \(name)"
                    } else {
                        message = "An error has occurred"
                        return
                    }
                    //self.delegate?.showDialog(message)
                    self.delegate?.showContentViewController(ambassadorship!)
                    
                }
            case 2:
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string : idin)!, options: [:], completionHandler: { (status) in })
                } else {
                    UIApplication.shared.openURL(URL(string : idin)!)
                }
            
            case 6:
                guard let number = URL(string: "tel://\(idin)") else { return }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(number, options: [:], completionHandler: { (status) in })
                } else {
                    UIApplication.shared.openURL(number)
                }
            case 7:
               
                delegatePaser?.showNewLink(link: idin)
                
//                guard let number = URL(string: "mailto:\(idin)") else { return }
//                if #available(iOS 10.0, *) {
//                    UIApplication.shared.open(number, options: [:], completionHandler: { (status) in })
//                } else {
//                    UIApplication.shared.openURL(number)
//                }
            case 8:
                
                Downloader.load(url: URL.init(string: idin)!, to: (content?.pages[currentPage].id)!) { (msg) in
                    //print("file download & save")
                    //self.delegate?.presentUseAlert("", "File download & save!")
                    //self.delegate?.showAlertOnCell("", msg)
                    
                    self.delegate?.showAlertForIndexOnCell("", message: msg, alertButtonTitles: ["OK"], alertButtonStyles: [.default], vc: UIViewController(), completion: { (index) in
                        //print("T##items: Any...##Any")
                        
                        guard let url = URL(string: idin) else { return }
                        UIApplication.shared.open(url)
                        
                    })
                }
            case 9:
                print("9")
            case 10:
                print("10")
            default:
                break
        }
            
            
            
//            AmbassadorshipManager.sharedInstance.requestAmbassadorhipWithCode(text, completion: {(ambassadorship, error) in
//                if let ambassadorship = ambassadorship {
//                    self.delegate?.successfullySignForNewAmbassadorship(ambassadorship)
//                    self.dismiss(animated: true, completion: nil)
//                } else {
//                    self.showAlertWithTitle(NSLocalizedString("CONNECTION_CODE_DOES_NOT_EXISTS", comment: ""), message: nil, completion: {
//                        textField.becomeFirstResponder()
//                    })
//                }
//            })
        }
    }
    
    
    func shareButtons(subPageNumber: Int) {
        
        let is_shareable = content?.pages[multiPageCollectionView.currentVerticalPage()].is_shareable ?? false
        let shareable = content?.shareable
        
        shareableBody =  (content?.pages[multiPageCollectionView.currentVerticalPage()].isBodyShare)!
        
        print("share = \(shareable ?? false), \(shareableBody ?? false)")
        
        if shareableBody {
            //facebookShareButton.isHidden = false //s.
            // instagramShareButton.isHidden = false
            //twitterShareButton.isHidden = false //s.
            useButton.isHidden = true
            shareButton.isHidden = true
            
        } else if shareable! && is_shareable {
            //facebookShareButton.isHidden = false //s.
           // instagramShareButton.isHidden = false
            //twitterShareButton.isHidden = false //s.
            useButton.isHidden = true
            shareButton.isHidden = true
        } else if shareable! && !is_shareable {
            facebookShareButton.isHidden = true
            //instagramShareButton.isHidden = true
            twitterShareButton.isHidden = true
            useButton.isHidden = false
            //shareButton.isHidden = false //s.
        } else if !shareable! && is_shareable {
            //facebookShareButton.isHidden = false //s.
            //instagramShareButton.isHidden = false
            //twitterShareButton.isHidden = false //s.
            useButton.isHidden = true
            shareButton.isHidden = true
        } else if !shareable! && !is_shareable {
            facebookShareButton.isHidden = true
            //instagramShareButton.isHidden = true
            twitterShareButton.isHidden = true
            useButton.isHidden = true
            shareButton.isHidden = true
        }
        
        if !linkView.isHidden {
            leftConstraint.constant = 94
        } else {
            leftConstraint.constant = 16
        }

    }
    
     /*
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
 */
    
    // MARK: BackgroundDelegate
    
    func setShareImage(_ imageView: UIImageView) {
        shareImageView = imageView
       // shareImageView.image = UIImage.init(named: "defaultneutralgender")
    }
    
    

    
    // MARK: - Actions
 
    @IBAction func facebookShareButtonPressed(_ sender: UIButton) {
        print("curr = \(currentPage)")
        if shareableBody {
            for comp in (content?.pages[multiPageCollectionView.currentVerticalPage()].components)! {
                  print("comp i = \(comp.type)")
                if comp.embedType == "youtube" {
                    delegate?.shareFacebookLink(comp.youtubeUrl!)
                    return
                }else if comp.type == .Image {
                    let imageView = UIImageView()
                    delegate?.shareFacebook(imageView, isBack: false, page: currentPage)
                    return
                }
            }
        }
        
        if let image = shareImageView {
            delegate?.shareFacebook(image, isBack: true, page: currentPage)
        }
    }
    
    @IBAction func goThereAction(_ sender: Any) {
        self.tap()
    }
    @IBAction func instagramShareButtonPressed(_ sender: UIButton) {
//        guard let image = shareImageView else { return }
//        delegate?.shareInstagram(image)
    }
    
    @IBAction func twitterShareButton(_ sender: Any) {
        if shareableBody {
            for comp in (content?.pages[multiPageCollectionView.currentVerticalPage()].components)! {
                print("comp i = \(comp.type)")
                if comp.embedType == "youtube" {
                    delegate?.shareTwitterLink(comp.youtubeUrl!)
                    return
                } else if comp.type == .Image {
                    let imageView = UIImageView()
                    delegate?.shareTwitter(imageView, isBack: false, page: currentPage)
                    return
                }
            }
        }
        
        if let image = shareImageView {
            delegate?.shareTwitter(image, isBack: true, page: currentPage)
        }
    }
    
    
    
    
    @IBAction func useButtonPressed(_ sender: UIButton) {
        
        var title = ""
        var message = "POTENTIAL SUBMESSAGE HERE"
        
        guard content != nil else { return }
        let consumeType = content?.consumeAction
        
        if consumeType == .information {
            title = "Information"
        } else if consumeType == .onlyConsumable {
            title = "Use"
        } else if consumeType == .link {
            title = "Follow link"
        } else if consumeType == .code {
            title = "Use the code below"
            message = "CODE IS PRESENTED HERE"
        } else if consumeType == .affiliate {
            title = "Would you like to become an affiliate"
        } else if consumeType == .document {
            title = "Open PDF Document"
        }
        
        
        
        delegate?.presentUseAlert(title, message)
       
        print("Use button pressed, activate functionality based on pages[].consume_action. document, affiliate, link works")
    }
    
    
    @IBAction func upButtonPressed(_ sender: UIButton) {
        scrollPage(-1)
    }
    
    @IBAction func downButtonPressed(_ sender: UIButton) {
        scrollPage(1)
    }
    
    @IBAction func shareButtonPressed(_ sender: AnyObject) {
        if let content = content {
            delegate?.shareContent(content.id)
        }
    }
    
    @IBAction func outboundShareButtonPressed(_ sender: Any) {
        if let content = content {
            delegate?.shareContentOutbound(content.id)
            
        }
    }
    
    // Problem?
    func scrollPage(_ direction: Int) {
        currentSubPage += direction
        multiPageCollectionView.scrollVertical(currentPage + direction, animated: true)
    }
    
    // MARK: - Animations
    
    func zoomBackground(_ x: CGFloat, y: CGFloat) {
        let indexPath = IndexPath(row: currentPage, section: 0)
        if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? SinglePage {
            cell.zoomBackground(x, y: y)
        }
    }
    
    
}

extension MultiPage: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let content = content {
            return content.pages.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageCell", for: indexPath) as! SinglePage
        
        if let content = content {
            cell.delegate = delegatePaser
            cell.BGDelegate = self
            let claimableCell = content.claimable && collectionView.isLastIndexPathInCollectionView(indexPath)
            let consumeAction = claimableCell ? content.consumeAction : nil
            let isShareable = content.shareable && collectionView.isLastIndexPathInCollectionView(indexPath)
            
            cell.configure(with: content,
                           consumeAction: consumeAction,
                           shareable: isShareable,
                           pageIndex: indexPath.item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageCell", for: indexPath) as! SinglePage
        cell.pauseMedia()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            self.multiLinkBaseView.removeFromSuperview()
            self.contentView.superview?.willRemoveSubview(multiLinkBaseView)
            
            self.base1.removeFromSuperview()
            self.contentView.superview?.willRemoveSubview(base1)
            self.base2.removeFromSuperview()
            self.contentView.superview?.willRemoveSubview(base2)
            self.base3.removeFromSuperview()
            self.contentView.superview?.willRemoveSubview(base3)
    }
    
    
    func handlePageButtons(_ page: Int) {
        
        if currentPage != page {
            let cell = multiPageCollectionView.dequeueReusableCell(withReuseIdentifier: "PageCell", for: IndexPath(row: currentPage, section: 0)) as! SinglePage
            cell.pauseMedia()
        }

        
        let isIdentity = content?.pages[page].identity
        if let idin = isIdentity, let action = content?.pages[page].consumeAction {
            print("connect = \(idin)")
            print("connect1 = \(action)")
            
            if action == 10 {
                let strArray = idin.components(separatedBy: ",") //s
                for (index,item) in strArray.enumerated() {
                    if index % 2 == 0 {
                        if item != "" {
                            self.arrContentID.append(item)
                        }
                        
                        //print(self.arrPageID)
                    }else {
                        if item != "" {
                            self.arrPageID.append(item)
                        }
                        
                        //print(self.arrContentID)
                    }
                }
            }
            
            self.linkView.isHidden = idin.starts(with: "information")
            OperationQueue.main.addOperation {
                self.goThereBtn.isHidden = true
            }
            label.text = ""
            var actionImage: UIImage? = nil
            
            self.baseView.removeFromSuperview()
            self.contentView.superview?.willRemoveSubview(baseView)
            
            self.multiLinkBaseView.removeFromSuperview()
            self.contentView.superview?.willRemoveSubview(multiLinkBaseView)
            
            self.base1.removeFromSuperview()
            self.contentView.superview?.willRemoveSubview(base1)
            self.base2.removeFromSuperview()
            self.contentView.superview?.willRemoveSubview(base2)
            self.base3.removeFromSuperview()
            self.contentView.superview?.willRemoveSubview(base3)
            
            
            switch action {
            case 1:
                actionImage = UIImage(named: "use3")
                
            case 2:
                actionImage = UIImage(named: "link")
                
                OperationQueue.main.addOperation {
                    self.linkView.isHidden = true
                    self.goThereBtn.isHidden = false;
                    self.goThereBtn.setTitle("Go There", for: .normal)
                }
               
            case 3:
                actionImage = UIImage(named: "code")
            case 4:
                actionImage = UIImage(named: "connect")
            case 5:
                //actionImage = UIImage(named: "read")
                
                OperationQueue.main.addOperation {
                    self.linkView.isHidden = true
                    self.goThereBtn.isHidden = false;
                    self.goThereBtn.setTitle("Read", for: .normal)
                }
                
            case 6:
                actionImage = UIImage(named: "phone")
            case 7:
                actionImage = UIImage(named: "mail")
                
                OperationQueue.main.addOperation {
                    self.linkView.isHidden = true
                    self.goThereBtn.isHidden = false;
                    self.goThereBtn.setTitle("Email", for: .normal)
                }
                
            case 8:
                //actionImage = UIImage(named: "read")
                
                OperationQueue.main.addOperation {
                    self.linkView.isHidden = true
                    self.goThereBtn.isHidden = false;
                    self.goThereBtn.setTitle("View Excel", for: .normal)
                }
                
            case 9:
                //actionImage = UIImage(named: "multiLink")
               
                OperationQueue.main.addOperation {
                    self.addMultiLinkOnView(page: (self.content?.pages[page])!)
                }
                
            case 10:
                //actionImage = UIImage(named: "inAppLink")
                
                OperationQueue.main.addOperation {
                    self.addInAppLinkOnView()
                }
                
            default:
                break
            }
            
            linkImageView.image = actionImage
//            switch action {
//                case 3:
//                    label.text = "GET"
//                case 1:
//                    label.text = "USE"
//                case 5:
//                    label.text = "READ"
//                case 2:
//                    label.text = "LINK"
//                case 6:
//                    label.text = "PHONE"
//                case 7:
//                    label.text = "MAIL"
//                case 4:
//                 label.text = "CONNECT"
//                default: break
//            }
        } else {
            
            OperationQueue.main.addOperation {
                self.linkView.isHidden = true
                self.goThereBtn.isHidden = true
                
            }
            
        }
    
//        linkView.isHidden = false
        
        if !linkView.isHidden {
            leftConstraint.constant = 94
        } else {
            leftConstraint.constant = 16
        }
        
        MultiPage.currPage = page
        currentPage = page
        if let content = content {
            upButton.isHidden = page == 0
            downButton.isHidden = content.pages.count - 1 == page
        }
    }
    
    func addInAppLinkOnView() {
        
        baseView = UIView.init(frame: CGRect.init(x: 10, y: 10, width: self.contentView.frame.size.width - 20, height: self.contentView.frame.size.height - 20))
        
        let btn1 = UIButton.init(frame: CGRect.init(x: 20, y: (self.contentView.frame.height * 17)/100, width: self.contentView.frame.size.width - 40, height: (self.contentView.frame.height * 12)/100))
        btn1.tag = 0
        btn1.addTarget(self, action: #selector(MultiPage.btnClickedInAppLink(_:)), for: .touchUpInside)
        btn1.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                
        let btn2 = UIButton.init(frame: CGRect.init(x: 20, y: btn1.frame.origin.y + btn1.frame.size.height + 20, width: self.contentView.frame.size.width - 40, height: (self.contentView.frame.height * 12)/100))
        btn2.tag = 1
        btn2.addTarget(self, action: #selector(MultiPage.btnClickedInAppLink(_:)), for: .touchUpInside)
        btn2.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        let btn3 = UIButton.init(frame: CGRect.init(x: 20, y: btn2.frame.origin.y + btn2.frame.size.height + 20, width: self.contentView.frame.size.width - 40, height: (self.contentView.frame.height * 12)/100))
        btn3.tag = 2
        btn3.addTarget(self, action: #selector(MultiPage.btnClickedInAppLink(_:)), for: .touchUpInside)
        btn3.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        let btn4 = UIButton.init(frame: CGRect.init(x: 20, y: btn3.frame.origin.y + btn3.frame.size.height + 20, width: self.contentView.frame.size.width - 40, height: (self.contentView.frame.height * 12)/100))
        btn4.tag = 3
        btn4.addTarget(self, action: #selector(MultiPage.btnClickedInAppLink(_:)), for: .touchUpInside)
        btn4.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        let btn5 = UIButton.init(frame: CGRect.init(x: 20, y: btn4.frame.origin.y + btn4.frame.size.height + 20, width: self.contentView.frame.size.width - 40, height: (self.contentView.frame.height * 12)/100))
        btn5.tag = 4
        btn5.addTarget(self, action: #selector(MultiPage.btnClickedInAppLink(_:)), for: .touchUpInside)
        btn5.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        baseView.addSubview(btn1)
        baseView.addSubview(btn2)
        baseView.addSubview(btn3)
        baseView.addSubview(btn4)
        baseView.addSubview(btn5)
        
        self.contentView.superview?.addSubview(baseView)
    
    }
    
    func addMultiLinkOnView(page : ContentPage) {
        
        multiLinkBaseView = UIStackView.init(frame: CGRect.init(x: 10, y: (self.contentView.frame.height * 20)/100, width: self.contentView.frame.size.width - 20, height: ((self.contentView.frame.width/4)*3.2)))
        
        multiLinkBaseView.axis = .vertical
        multiLinkBaseView.distribution = .fillEqually
        multiLinkBaseView.alignment = .fill
        multiLinkBaseView.spacing = 15.0
        
        
        //base1 = UIView.init(frame: CGRect.init(x: 20, y: (self.contentView.frame.height * 20)/100, width: (self.contentView.frame.width - 40), height: (self.contentView.frame.width/4)))
        base1 = UIView.init(frame: CGRect.init(x: 20, y: 10, width: (self.contentView.frame.width - 40), height: (self.contentView.frame.width/4)))
        let img1 = UIImageView.init(frame: CGRect.init(x: 20, y: 15, width: (base1.frame.width/3 - 50), height: (base1.frame.width/3 - 50)))
        let lbl1 = UILabel.init(frame: CGRect.init(x: img1.frame.origin.x + img1.frame.size.width + 10, y: base1.frame.size.height/4 - 10, width: base1.frame.size.width/2 + 80, height: img1.frame.size.height))
        lbl1.lineBreakMode = NSLineBreakMode.byWordWrapping
        lbl1.numberOfLines = 0

        
        lbl1.font = lbl1.font.withSize(20)
        if let txt = page.components[3].meta?.text {
            lbl1.text = txt
        }
//        if let bg = page.components[3].meta?.bgColor {
//            lbl1.backgroundColor = bg
//        }
        if let col = page.components[3].meta?.color {
            lbl1.textColor = col
        }
        if let size = page.components[3].meta?.size {
            lbl1.font = lbl1.font.withSize(size)
        }
        if let font = page.components[3].meta?.font {
            lbl1.font = font
        }
        if let alignment = page.components[3].meta?.textAlignment {
            lbl1.textAlignment = alignment
        }
        if let link = page.components[2].meta?.text {
            if link.hasPrefix("http://") || link.hasPrefix("https://") {
                link1 = link
            }else {
                link1 = "http://\(link)"
            }
            
            //link1 = link
        }
    
        
        let btn1 = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: base1.frame.size.width, height: base1.frame.size.height))
        btn1.tag = 1
        btn1.addTarget(self, action: #selector(MultiPage.btnClickedMultiLink(_:)), for: .touchUpInside)
        btn1.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        
        
        //base2 = UIView.init(frame: CGRect.init(x: 20, y: base1.frame.origin.y + base1.frame.size.height + 15, width: (self.contentView.frame.width - 40), height: (self.contentView.frame.width/4)))
        base2 = UIView.init(frame: CGRect.init(x: 20, y: base1.frame.origin.y + base1.frame.size.height + 15, width: (self.contentView.frame.width - 40), height: (self.contentView.frame.width/4)))
        
        let img2 = UIImageView.init(frame: CGRect.init(x: 20, y: 15, width: (base2.frame.width/3 - 50), height: (base2.frame.width/3 - 50)))
        let lbl2 = UILabel.init(frame: CGRect.init(x: img2.frame.origin.x + img2.frame.size.width + 10, y: base2.frame.size.height/4 - 10, width: base2.frame.size.width/2 + 80, height: img2.frame.size.height))
        lbl2.lineBreakMode = NSLineBreakMode.byWordWrapping
        lbl2.numberOfLines = 0

        
        lbl2.font = lbl2.font.withSize(20)
        if let txt = page.components[5].meta?.text {
            lbl2.text = txt
        }
//        if let bg = page.components[5].meta?.bgColor {
//            lbl2.backgroundColor = bg
//        }
        if let col = page.components[5].meta?.color {
            lbl2.textColor = col
        }
        if let size = page.components[5].meta?.size {
            lbl2.font = lbl2.font.withSize(size)
        }
        if let font = page.components[5].meta?.font {
            lbl2.font = font
        }
        if let alignment = page.components[5].meta?.textAlignment {
            lbl2.textAlignment = alignment
        }
        if let link = page.components[4].meta?.text {
            if link.hasPrefix("http://") || link.hasPrefix("https://") {
                link2 = link
            }else {
                link2 = "http://\(link)"
            }
            
            //link2 = link
        }
        
        let btn2 = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: base2.frame.size.width, height: base2.frame.size.height))
        btn2.tag = 2
        btn2.addTarget(self, action: #selector(MultiPage.btnClickedMultiLink(_:)), for: .touchUpInside)
        btn2.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        
        
        //base3 = UIView.init(frame: CGRect.init(x: 20, y: base2.frame.origin.y + base2.frame.size.height + 15, width: (self.contentView.frame.width - 40), height: (self.contentView.frame.width/4)))
        base3 = UIView.init(frame: CGRect.init(x: 20, y: base2.frame.origin.y + base2.frame.size.height + 15, width: (self.contentView.frame.width - 40), height: (self.contentView.frame.width/4)))
        
        let img3 = UIImageView.init(frame: CGRect.init(x: 20, y: 15, width: (base3.frame.width/3 - 50), height: (base3.frame.width/3 - 50)))
        let lbl3 = UILabel.init(frame: CGRect.init(x: img3.frame.origin.x + img3.frame.size.width + 10, y: base3.frame.size.height/4 - 10, width: base3.frame.size.width/2 + 80, height: img3.frame.size.height))
        lbl3.lineBreakMode = NSLineBreakMode.byWordWrapping
        lbl3.numberOfLines = 0
        
    
        lbl3.font = lbl3.font.withSize(20)
        if let txt = page.components[7].meta?.text {
            lbl3.text = txt
        }
//        if let bg = page.components[7].meta?.bgColor {
//            lbl3.backgroundColor = bg
//        }
        if let col = page.components[7].meta?.color {
            lbl3.textColor = col
        }
        if let size = page.components[7].meta?.size {
            lbl3.font = lbl3.font.withSize(size)
        }
        if let font = page.components[7].meta?.font {
            lbl3.font = font
        }
        if let alignment = page.components[7].meta?.textAlignment {
            lbl3.textAlignment = alignment
        }
        if let link = page.components[6].meta?.text {
            if link.hasPrefix("http://") || link.hasPrefix("https://") {
                link3 = link
            }else {
                link3 = "http://\(link)"
            }
            
            //link3 = link
        }
        
        let btn3 = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: base3.frame.size.width, height: base3.frame.size.height))
        btn3.tag = 3
        btn3.addTarget(self, action: #selector(MultiPage.btnClickedMultiLink(_:)), for: .touchUpInside)
        btn3.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        
        base1.addSubview(img1)
        base1.addSubview(lbl1)
        base1.addSubview(btn1)
        base1.backgroundColor = #colorLiteral(red: 0.4117647059, green: 0.4156862745, blue: 0.4274509804, alpha: 1)
        self.multiLinkBaseView.addArrangedSubview(base1)
        //self.contentView.superview?.addSubview(base1)
        
        base2.addSubview(img2)
        base2.addSubview(lbl2)
        base2.addSubview(btn2)
        base2.backgroundColor = #colorLiteral(red: 0.4117647059, green: 0.4156862745, blue: 0.4274509804, alpha: 1)
        self.multiLinkBaseView.addArrangedSubview(base2)
        //self.contentView.superview?.addSubview(base2)
        
        base3.addSubview(img3)
        base3.addSubview(lbl3)
        base3.addSubview(btn3)
        base3.backgroundColor = #colorLiteral(red: 0.4117647059, green: 0.4156862745, blue: 0.4274509804, alpha: 1)
        self.multiLinkBaseView.addArrangedSubview(base3)
        //self.contentView.superview?.addSubview(base3)
        
        //self.contentView.superview?.addSubview(multiLinkBaseView)
        self.addSubview(multiLinkBaseView)
 
       
        //let arr = [page.backgrounds]
        let arr = page.multiLinkBackgrounds
        
        
        for (_,item) in arr.enumerated() {
            
            if item.order == 1 {
                
                if (item.type).rawValue == "image" {
                    if let url1 = item.file_url {
                        img1.af_setImage(withURL: URL.init(string: url1)!)
                        
                        
                        img1.isHidden = false
                        lbl1.isHidden = false
                        btn1.isHidden = false
                        base1.isHidden = false
                    }else {
                        img1.isHidden = true
                        lbl1.isHidden = true
                        btn1.isHidden = true
                        base1.isHidden = true
                    }
                }else {
                    if let col1 = item.meta?["box_color"] as? String {
                        img1.backgroundColor = UIColor(hexString: col1)
                        
                        
                        img1.isHidden = false
                        lbl1.isHidden = false
                        btn1.isHidden = false
                        base1.isHidden = false
                    }else {
                        img1.isHidden = true
                        lbl1.isHidden = true
                        btn1.isHidden = true
                        base1.isHidden = true
                    }
                }
                
            }
            
            if item.order == 2 {
                
                if (item.type).rawValue == "image" {
                    if let url2 = item.file_url {
                        img2.af_setImage(withURL: URL.init(string: url2)!)
                        
                        
                        img2.isHidden = false
                        lbl2.isHidden = false
                        btn2.isHidden = false
                        base2.isHidden = false
                    }else {
                        img2.isHidden = true
                        lbl2.isHidden = true
                        btn2.isHidden = true
                        base2.isHidden = true
                    }
                }else {
                    if let col2 = item.meta?["box_color"] as? String {
                        img2.backgroundColor = UIColor(hexString: col2)
                        
                        
                        img2.isHidden = false
                        lbl2.isHidden = false
                        btn2.isHidden = false
                        base2.isHidden = false
                    }else {
                        img2.isHidden = true
                        lbl2.isHidden = true
                        btn2.isHidden = true
                        base2.isHidden = true
                    }
                }
                
            }
            
            if item.order == 3 {
                
                if (item.type).rawValue == "image" {
                    if let url3 = item.file_url {
                        img3.af_setImage(withURL: URL.init(string: url3)!)
                        
                        
                        img3.isHidden = false
                        lbl3.isHidden = false
                        btn3.isHidden = false
                        base3.isHidden = false
                    }else {
                        img3.isHidden = true
                        lbl3.isHidden = true
                        btn3.isHidden = true
                        base3.isHidden = true
                    }
                }else {
                    if let col3 = item.meta?["box_color"] as? String {
                        img3.backgroundColor = UIColor(hexString: col3)
                        
                        
                        img3.isHidden = false
                        lbl3.isHidden = false
                        btn3.isHidden = false
                        base3.isHidden = false
                    }else {
                        img3.isHidden = true
                        lbl3.isHidden = true
                        btn3.isHidden = true
                        base3.isHidden = true
                    }
                }
                
            }
        }
        
        var firstLine = true
        var secondLine = true
        var thirdLine = true
        
        
        //To Manage Views according to text exist
        if let txt = page.components[3].meta?.text {
            //lbl1.text = txt
            
            if txt != "" {
                img1.isHidden = false
                lbl1.isHidden = false
                btn1.isHidden = false
                base1.isHidden = false
            }else {
                firstLine = false
                
                img1.isHidden = true
                lbl1.isHidden = true
                btn1.isHidden = true
                base1.isHidden = true
            }
            
        }else {
            
            firstLine = false
            
            img1.isHidden = true
            lbl1.isHidden = true
            btn1.isHidden = true
            base1.isHidden = true
            
        }
        
        if let txt = page.components[5].meta?.text {
            //lbl2.text = txt
            
            if txt != "" {
                img2.isHidden = false
                lbl2.isHidden = false
                btn2.isHidden = false
                base2.isHidden = false
            }else {
                secondLine = false
                
                img2.isHidden = true
                lbl2.isHidden = true
                btn2.isHidden = true
                base2.isHidden = true
            }
            
        }else {
            
            secondLine = false
            
            img2.isHidden = true
            lbl2.isHidden = true
            btn2.isHidden = true
            base2.isHidden = true
            
        }
        
        if let txt = page.components[7].meta?.text {
            //lbl3.text = txt
            
            if txt != "" {
                img3.isHidden = false
                lbl3.isHidden = false
                btn3.isHidden = false
                base3.isHidden = false
            }else {
                thirdLine = false
                
                img3.isHidden = true
                lbl3.isHidden = true
                btn3.isHidden = true
                base3.isHidden = true
            }
            
        }else {
            thirdLine = false
            
            img3.isHidden = true
            lbl3.isHidden = true
            btn3.isHidden = true
            base3.isHidden = true
        }
        
        if firstLine && secondLine && thirdLine {
            self.multiLinkBaseView.frame.size.height = ((self.contentView.frame.width/4)*3.2)
        }else if firstLine && secondLine {
            self.multiLinkBaseView.frame.size.height = ((self.contentView.frame.width/4)*2.2)
        }else if firstLine && thirdLine {
            self.multiLinkBaseView.frame.size.height = ((self.contentView.frame.width/4)*2.2)
        }else if secondLine && thirdLine {
            self.multiLinkBaseView.frame.size.height = ((self.contentView.frame.width/4)*2.2)
        }else if firstLine || secondLine || thirdLine {
            self.multiLinkBaseView.frame.size.height = ((self.contentView.frame.width/4)*1.2)
        }else {
            self.multiLinkBaseView.frame.size.height = 0
        }

        //self.contentView.superview?.addSubview(multiLinkBaseView)
        
    }
    
    
    @objc func btnClickedMultiLink(_ sender : UIButton) {
        
        switch sender.tag {
        case 1:
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string : link1)!, options: [:], completionHandler: { (status) in })
            } else {
                UIApplication.shared.openURL(URL(string : link1)!)
            }
        case 2:
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string : link2)!, options: [:], completionHandler: { (status) in })
            } else {
                UIApplication.shared.openURL(URL(string : link2)!)
            }
        default:
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string : link3)!, options: [:], completionHandler: { (status) in })
            } else {
                UIApplication.shared.openURL(URL(string : link3)!)
            }
        }
    
    }
    
    
    @objc func btnClickedInAppLink(_ sender : UIButton) {
        
        guard arrContentID.count > sender.tag else {
            return
        }
        
        let contId = arrContentID[sender.tag]
        let pageId = arrPageID[sender.tag]
        
        let indexOfContentID = actualContents.firstIndex(where: { $0.id == Int(contId) })
        print(indexOfContentID ?? 0)
        self.click = false
        //self.content = actualContents[indexOfContentID ?? 0]
        
        let indexOfPageID = self.content?.pages.firstIndex(where: { $0.id == Int(pageId) })
        print(indexOfPageID ?? 0)
        
        if let load = loadCollectionView {
            load(IndexPath.init(row: indexOfContentID ?? 0, section: indexOfPageID ?? 0))
        }
        
    }
    
}


extension MultiPage : UIScrollViewDelegate, UICollectionViewDelegate {
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        OperationQueue.main.addOperation {
            self.goThereBtn.isHidden = true
        }
        var scrollOffset = scrollView.contentOffset.y
        let contentHeight = multiPageCollectionView.contentSize.height - multiPageCollectionView.frame.size.height
        var indexPath:IndexPath?
        if scrollOffset < 0 {
            indexPath = IndexPath(row: 0, section: 0)
        } else if scrollOffset > contentHeight {
            indexPath = IndexPath(row: multiPageCollectionView.numberOfVerticalPages()-1, section: 0)
            scrollOffset = scrollOffset - contentHeight
        }
        if let indexPath = indexPath {
            if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? MultiPage {
                cell.zoomBackground(0, y: scrollOffset)
            } else if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? SinglePage {
                cell.zoomBackground(0, y: scrollOffset)
            }
        }

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        calculateCurrentPageNumber()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        calculateCurrentPageNumber()
    }
    
    func calculateCurrentPageNumber() {
        OperationQueue.main.addOperation {
            self.goThereBtn.isHidden = true
        }

        let page = multiPageCollectionView.currentVerticalPage()
        currentSubPage += multiPageCollectionView.currentVerticalPage()
        
        
        //getFileUrl((content?.pages[multiPageCollectionView.currentVerticalPage()].backgrounds)!)
        shareButtons(subPageNumber: multiPageCollectionView.currentVerticalPage())
        
        handlePageButtons(page)

    }
    
    
}

class Downloader {
    class func load(url: URL, to localFileName: Int, completion: @escaping (_ msg:String) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = try! URLRequest(url: url, method: .get)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let _ = tempLocalUrl, error == nil {
                
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
              
                
                let fileName = "\(localFileName).xls"
                //let fileName = downloadTask.originalRequest?.url?.lastPathComponent
                let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                let documentDirectoryPath:String = path[0]
                let fileManager = FileManager()
                
                //var destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appending("/Folder")) //\(String(describing: fileName!))
                
                var destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath)
                
                //if fileManager.fileExists(atPath: documentDirectoryPath) {
                    //completion("File Already Downloaded & Exist!")
                //}else {
                    
                    do {
                        //try fileManager.createDirectory(at: destinationURLForFile, withIntermediateDirectories: true, attributes: nil)
                        destinationURLForFile.appendPathComponent(String(describing: fileName))
                        
                        if fileManager.fileExists(atPath: destinationURLForFile.path) {
                            completion("File Already Exist!")
                        }else {
                            
                            try fileManager.moveItem(at: tempLocalUrl ?? URL.init(string: "")!, to: destinationURLForFile)
                            
                            completion("File Download & Save!")
                            
                        }
                        
                    }catch(let error){
                        print(error)
                        completion("File Download but Unable Save!")
                    }
                    
                //}
                
                
                
                
                
                /*
                do {
                    let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil,create: false)
                    
                    let savedURL = documentsURL.appendingPathComponent("\(fileName)")
                    print(savedURL)
                    
                    try FileManager.default.moveItem(at: savedURL, to: tempLocalUrl!)
                    
                    completion("File Download & Save!")
                    
                } catch {
                    print ("file error :-->> \(error)")
                    completion("File Download but Unable Save!")
                }*/
                
            } else {
                print("Failure: %@", error?.localizedDescription ?? "")
                completion("File Download Failed!")
            }
        }
        task.resume()
    }
   
    
}
