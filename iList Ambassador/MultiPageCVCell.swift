//
//  MultiPageCVCell.swift
//  AppIn
//
//  Created by sameer khan on 28/06/20.
//  Copyright © 2020 Sameer khan. All rights reserved.
//

import UIKit

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
    
    func openLinkInAppInWebView(link: String)
    func openEmailLink(link: String)
}

var linkOpenInWebView : ((_ url:String)-> (Void))?

class MultiPageCVCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var multiPageCollectionView: UICollectionView!
    @IBOutlet weak var goThereBtn: UIButton!
    @IBOutlet weak var downButton: BounchingButton!
    @IBOutlet weak var upButton: UIButton!
    
    var delegate: MultiPageDelegate?
    var closeCell = true
    
    static var currPage = 0
    
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
                
    var content:Content? {
        didSet {
            
            if (content != nil) {
                
                currentPage = 0
                
                self.multiPageCollectionView.register(UINib(nibName: "ContentImageCVCell", bundle: nil), forCellWithReuseIdentifier: "ContentImageCVCell")
                self.multiPageCollectionView.register(UINib(nibName: "ContentTextCVCell", bundle: nil), forCellWithReuseIdentifier: "ContentTextCVCell")
                self.multiPageCollectionView.register(UINib(nibName: "ContentVideoCVCell", bundle: nil), forCellWithReuseIdentifier: "ContentVideoCVCell")
                self.multiPageCollectionView.register(UINib(nibName: "ContentSoundCVCell", bundle: nil), forCellWithReuseIdentifier: "ContentSoundCVCell")
                self.multiPageCollectionView.register(UINib(nibName: "ContentYoutubeCVCell", bundle: nil), forCellWithReuseIdentifier: "ContentYoutubeCVCell")
                self.multiPageCollectionView.register(UINib(nibName: "ContentVimeoCVCell", bundle: nil), forCellWithReuseIdentifier: "ContentVimeoCVCell")

                if multiPageCollectionView.dataSource == nil {
                    multiPageCollectionView.delegate = self
                    multiPageCollectionView.dataSource = self
                }
                
                multiPageCollectionView.reloadData()
                multiPageCollectionView.performBatchUpdates({
                    print("Loaded done")
                }) { (result) in
                    print(result)
                    
                    if let raw = selectedRaw {
                        
                        self.multiPageCollectionView.scrollToItem(at: IndexPath.init(row: raw, section: 0), at: [.centeredHorizontally,.centeredVertically], animated: false)
                        
                        self.handlePageButtons(raw)
                        
                        selectedRaw = nil
                    }
                }
                            
                if let raw = selectedRaw {
                    self.handlePageButtons(raw)
                }else {
                    self.handlePageButtons(0)
                }
                
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        linkOpenInWebView = { link in
            DispatchQueue.main.async {
                self.delegate?.openLinkInAppInWebView(link: link)
            }
        }
        
    }
    
    //MARK: UICollectionView DataSource & Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content?.pages.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        autoreleasepool {
            
            let page = self.content?.pages[indexPath.row]
            let comp = page?.components
            
            let component0 = comp?.first
            let component1 = comp?[1]
            
                        
            switch component1?.type {
                
            case .Image:
                let imageCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentImageCVCell", for: indexPath) as! ContentImageCVCell
                                
                imageCVCell.component0 = component0
                imageCVCell.component1 = component1
                
                if let backGround = page?.backgrounds {
                    imageCVCell.background = backGround
                }
                
                if let strSticker = page?.frameUrl {
                    imageCVCell.stickerURL = strSticker
                }
              
                imageCVCell.content = self.content
                imageCVCell.pageNo = indexPath.row
                
                return imageCVCell
                
            case .Text:
                let textCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentTextCVCell", for: indexPath) as! ContentTextCVCell
                
                textCVCell.component0 = component0
                textCVCell.component1 = component1
                
                if let backGround = page?.backgrounds {
                    textCVCell.background = backGround
                }
                
                if let strSticker = page?.frameUrl {
                    textCVCell.stickerURL = strSticker
                }
              
                textCVCell.content = self.content
                textCVCell.pageNo = indexPath.row
                
                return textCVCell
            case .Video:
                let videoCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentVideoCVCell", for: indexPath) as! ContentVideoCVCell
                
                videoCVCell.component0 = component0
                videoCVCell.component1 = component1
                
                if let backGround = page?.backgrounds {
                    videoCVCell.background = backGround
                }
                
                if let strSticker = page?.frameUrl {
                    videoCVCell.stickerURL = strSticker
                }
                
                videoCVCell.content = self.content
                videoCVCell.pageNo = indexPath.row
                
                return videoCVCell
            case .Sound:
                let soundCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentSoundCVCell", for: indexPath) as! ContentSoundCVCell
                
                soundCVCell.music?.removeFromSuperview()
                
                soundCVCell.component0 = component0
                soundCVCell.component1 = component1
            
                
                if let backGround = page?.backgrounds {
                    soundCVCell.background = backGround
                }
                
                if let strSticker = page?.frameUrl {
                    soundCVCell.stickerURL = strSticker
                }
              
                soundCVCell.content = self.content
                soundCVCell.pageNo = indexPath.row
                
                return soundCVCell
            case .Embed:
                
                if component1?.embedType == "youtube" {
                    
                    let youtubeCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentYoutubeCVCell", for: indexPath) as! ContentYoutubeCVCell

                    youtubeCVCell.component0 = component0
                    youtubeCVCell.component1 = component1

                    if let backGround = page?.backgrounds {
                        youtubeCVCell.background = backGround
                    }

                    if let strSticker = page?.frameUrl {
                        youtubeCVCell.stickerURL = strSticker
                    }
                    
                    youtubeCVCell.content = self.content
                    youtubeCVCell.pageNo = indexPath.row

                    return youtubeCVCell
                                        
                }else if component1?.embedType == "vimeo" {
                    
                    let vimeoCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentVimeoCVCell", for: indexPath) as! ContentVimeoCVCell
                    
                    vimeoCVCell.component0 = component0
                    vimeoCVCell.component1 = component1
                    
                    if let backGround = page?.backgrounds {
                        vimeoCVCell.background = backGround
                    }
                    
                    if let strSticker = page?.frameUrl {
                        vimeoCVCell.stickerURL = strSticker
                    }
                  
                    vimeoCVCell.content = self.content
                    vimeoCVCell.pageNo = indexPath.row
                    
                    return vimeoCVCell
                }
                
            case .none:
                print("image")
            }
            
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        autoreleasepool {
            
            if let cell = cell as? ContentImageCVCell {
                cell.pauseMedia()
                
                if let pause = cell.pauseImageMp3 {
                    pause()
                }
            }
            
            if let cell = cell as? ContentTextCVCell {
                cell.pauseMedia()
                
                if let pause = cell.pauseTextMp3 {
                    pause()
                }
            }
            
            if let cell = cell as? ContentVideoCVCell {
                cell.pauseMedia()
                
                if let pause = cell.pauseVideoMp3 {
                    pause()
                }
            }
            
            if let cell = cell as? ContentSoundCVCell {
                cell.pauseMedia()
                
                if let pause = cell.pauseSoundMp3 {
                    pause()
                }
            }
            
            if let cell = cell as? ContentYoutubeCVCell {
                cell.pauseMedia()
                
                if let pause = cell.pauseYoutubeMp3 {
                    pause()
                }
            }
            
            if let cell = cell as? ContentVimeoCVCell {
                cell.pauseMedia()
                
                if let pause = cell.pauseVimeoMp3 {
                    pause()
                }
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        autoreleasepool {
            
            guard closeCell else {
                closeCell = true
                
                return
            }
            
            if let cell = cell as? ContentImageCVCell {
                if let mp3 = self.content?.pages[indexPath.row].BackSoundUrl {
                    cell.mp3URL = mp3
                }
            }
            
            if let cell = cell as? ContentTextCVCell {
                if let mp3 = self.content?.pages[indexPath.row].BackSoundUrl {
                    cell.mp3URL = mp3
                }
            }
            
            if let cell = cell as? ContentVideoCVCell {
                if let mp3 = self.content?.pages[indexPath.row].BackSoundUrl {
                    cell.mp3URL = mp3
                }
            }
            
            if let cell = cell as? ContentSoundCVCell {
                if let mp3 = self.content?.pages[indexPath.row].BackSoundUrl {
                    cell.mp3URL = mp3
                }
            }
            
            if let cell = cell as? ContentYoutubeCVCell {
                if let mp3 = self.content?.pages[indexPath.row].BackSoundUrl {
                    cell.mp3URL = mp3
                }
            }
            
            if let cell = cell as? ContentVimeoCVCell {
                if let mp3 = self.content?.pages[indexPath.row].BackSoundUrl {
                    cell.mp3URL = mp3
                }
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
        return CGSize(width: self.multiPageCollectionView.bounds.width, height: self.multiPageCollectionView.bounds.height)
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
    
    //MARK: IBActions
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
        if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? ContentImageCVCell {
            cell.zoomBackground(x, y: y)
        }
        if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? ContentTextCVCell {
            cell.zoomBackground(x, y: y)
        }
        if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? ContentVideoCVCell {
            cell.zoomBackground(x, y: y)
        }
        if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? ContentSoundCVCell {
            cell.zoomBackground(x, y: y)
        }
        if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? ContentYoutubeCVCell {
            cell.zoomBackground(x, y: y)
        }
        if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? ContentVimeoCVCell {
            cell.zoomBackground(x, y: y)
        }
    }
    
    @IBAction func goThereButtonClicked(_ sender: UIButton) {
        
        print("testTap = \(currentPage)")
        
        if let idin = content?.pages[currentPage].identity, let action = content?.pages[currentPage].consumeAction {
            
            print("--- IDIN --- \(idin) ----- ACTION ----- \(action)")
            
            switch action {
                
            case 0:
                print("0 - Information")
                
            case 1:
                
                print("1 - Consumable")
                
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
                
            case 2:
                print("2 - link")
                
                DispatchQueue.main.async {
                    self.delegate?.openLinkInAppInWebView(link: idin)
                }
                
            case 3:
                print("3 - Code")
                
                DispatchQueue.main.async {
                    self.delegate?.showMessage("This is your code", idin)
                }
                
            case 4:
                print("4 - Affiliate")
                
                AmbassadorshipManager.sharedInstance.requestAmbassadorhipWithCode(idin) { (ambassadorship, error, code) in
                    var message = ""
                    print("code = \(code)")
                    
                    if error != nil {
                        message = "Server error"
                    } else if ambassadorship == nil {
                        message = "You are already an ambassador for this brand"
                        //self.presentUseAlert("You are already an ambassador for this brand", "")
                        
                        return
                    } else if code == 200 || code == 201 {
                        let name = ambassadorship?.brand.name == nil ? "" : ambassadorship!.brand.name
                        message = "You have successfully connected to \(name)"
                    } else {
                        message = "An error has occurred"
                        return
                    }
                    //self.delegate?.showDialog(message)
                    DispatchQueue.main.async {
                        self.delegate?.showContentViewController(ambassadorship!)
                    }
                    
                }
                
            case 5:
                print("5 - Document")
                
                DispatchQueue.main.async {
                    self.delegate?.openLinkInAppInWebView(link: idin)
                }
                
            case 6:
                print("6 - phone")
                
                DispatchQueue.main.async {
                    guard let number = URL(string: "tel://\(idin)") else { return }
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(number, options: [:], completionHandler: { (status) in })
                    } else {
                        UIApplication.shared.openURL(number)
                    }
                }
                
            case 7:
                print("7 - email")
                
                DispatchQueue.main.async {
                    self.delegate?.openEmailLink(link: idin)
                }
                
            case 8:
                print("8 - Excel")
                
                Downloader.load(url: URL.init(string: idin)!, to: (content?.pages[currentPage].id)!) { (msg) in
                    
                    DispatchQueue.main.async {
                        
                        self.delegate?.showAlertForIndexOnCell("", message: msg, alertButtonTitles: ["OK"], alertButtonStyles: [.default], vc: UIViewController(), completion: { (index) in
                            
                            DispatchQueue.main.async {
                                self.delegate?.openLinkInAppInWebView(link: idin)
                            }
                            
                        })
                    }
                }
                
            case 9:
                print("9 - MultiLink")
                
            case 10:
                print("10 - InAppLink")

            default:
                break
            }
            
        }
        
    }
    
    //MARK: Custom Methods
    
    func reset() {
        if let content = content, content.pages.count > 0 {
            multiPageCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        pauseCells()
    }
    
    func pauseCells() {
        
        if let cells = multiPageCollectionView.visibleCells as? [ContentImageCVCell] {
            for cell in cells {
                cell.pauseMedia()
                
                if let pause = cell.pauseImageMp3 {
                    pause()
                }
            }
        }
        
        if let cells = multiPageCollectionView.visibleCells as? [ContentTextCVCell] {
            for cell in cells {
                cell.pauseMedia()
                
                if let pause = cell.pauseTextMp3 {
                    pause()
                }
            }
        }
        
        if let cells = multiPageCollectionView.visibleCells as? [ContentVideoCVCell] {
            for cell in cells {
                cell.pauseMedia()
                
                if let pause = cell.pauseVideoMp3 {
                    pause()
                }
            }
        }
        
        if let cells = multiPageCollectionView.visibleCells as? [ContentSoundCVCell] {
            for cell in cells {
                cell.pauseMedia()
                
                if let pause = cell.pauseSoundMp3 {
                    pause()
                }
            }
        }
        
        if let cells = multiPageCollectionView.visibleCells as? [ContentYoutubeCVCell] {
            for cell in cells {
                cell.pauseMedia()
                
                if let pause = cell.pauseYoutubeMp3 {
                    pause()
                }
            }
        }
        
        if let cells = multiPageCollectionView.visibleCells as? [ContentVimeoCVCell] {
            for cell in cells {
                cell.pauseMedia()
                
                if let pause = cell.pauseVimeoMp3 {
                    pause()
                }
            }
        }
        
    }
    
    func handlePageButtons(_ page: Int) {
        
        if currentPage != page {
            //let cell = multiPageCollectionView.dequeueReusableCell(withReuseIdentifier: "PageCell", for: IndexPath(row: currentPage, section: 0)) as! SinglePage
            //cell.pauseMedia()
            
            if let cell = multiPageCollectionView.dequeueReusableCell(withReuseIdentifier: "ContentImageCVCell", for: IndexPath(row: currentPage, section: 0)) as? ContentImageCVCell {
                cell.pauseMedia()
            }
            if let cell = multiPageCollectionView.dequeueReusableCell(withReuseIdentifier: "ContentTextCVCell", for: IndexPath(row: currentPage, section: 0)) as? ContentTextCVCell {
                cell.pauseMedia()
            }
            if let cell = multiPageCollectionView.dequeueReusableCell(withReuseIdentifier: "ContentVideoCVCell", for: IndexPath(row: currentPage, section: 0)) as? ContentVideoCVCell {
                cell.pauseMedia()
            }
            if let cell = multiPageCollectionView.dequeueReusableCell(withReuseIdentifier: "ContentSoundCVCell", for: IndexPath(row: currentPage, section: 0)) as? ContentSoundCVCell {
                cell.pauseMedia()
            }
            if let cell = multiPageCollectionView.dequeueReusableCell(withReuseIdentifier: "ContentYoutubeCVCell", for: IndexPath(row: currentPage, section: 0)) as? ContentYoutubeCVCell {
                cell.pauseMedia()
            }
            if let cell = multiPageCollectionView.dequeueReusableCell(withReuseIdentifier: "ContentVimeoCVCell", for: IndexPath(row: currentPage, section: 0)) as? ContentVimeoCVCell {
                cell.pauseMedia()
            }
        }
        
        let isIdentity = content?.pages[page].identity
        if let idin = isIdentity, let action = content?.pages[page].consumeAction {
            print("connect = \(idin)")
            print("connect1 = \(action)")
         
            //To handle case of MultiLink & InAppLink
            
            switch action {
            case 0:
                print("0 - Information")
                // no action button
                
                OperationQueue.main.addOperation {
                    self.goThereBtn.isHidden = true
                }
                
            case 1:
                print("1 - Consumable")
                // no action button
                
                OperationQueue.main.addOperation {
                    self.goThereBtn.isHidden = false
                    self.goThereBtn.setTitle("Use Offer", for: .normal)
                }
                
            case 2:
                print("2 - link")
                
                OperationQueue.main.addOperation {
                    self.goThereBtn.isHidden = false
                    self.goThereBtn.setTitle("Go There", for: .normal)
                }
                
            case 3:
                print("3 - Code")
                
                OperationQueue.main.addOperation {
                    self.goThereBtn.isHidden = false
                    self.goThereBtn.setTitle("Get Code", for: .normal)
                }
                
            case 4:
                print("4 - Affiliate")
                
                OperationQueue.main.addOperation {
                    self.goThereBtn.isHidden = false
                    self.goThereBtn.setTitle("Connect to channel", for: .normal)
                }
                
            case 5:
                print("5 - Document")
                    
                OperationQueue.main.addOperation {
                    self.goThereBtn.isHidden = false
                    self.goThereBtn.setTitle("Read", for: .normal)
                }
                
            case 6:
                print("6 - phone")
                
                OperationQueue.main.addOperation {
                    self.goThereBtn.isHidden = false
                    self.goThereBtn.setTitle("Call", for: .normal)
                }
                
            case 7:
                print("7 - email")
                
                OperationQueue.main.addOperation {
                    self.goThereBtn.isHidden = false
                    self.goThereBtn.setTitle("Email", for: .normal)
                }
                
            case 8:
                print("8 - Excel")
                
                OperationQueue.main.addOperation {
                    self.goThereBtn.isHidden = false
                    self.goThereBtn.setTitle("View Excel", for: .normal)
                }
                
            case 9:
                print("9 - MultiLink")
                
                OperationQueue.main.addOperation {
                    self.goThereBtn.isHidden = true
                    
                    //self.addMultiLinkOnView(page: (self.content?.pages[page])!)
                }
                
            case 10:
                print("10 - InAppLink")
                
                OperationQueue.main.addOperation {
                    self.goThereBtn.isHidden = true
                    
                    //self.addInAppLinkOnView()
                }
                
            default:
                break
            }
            
           
            //New Functionality For GoThereButton
            if let consumeActionComp = content?.pages[page].consumeActionComponent {
                
                if let backBox = consumeActionComp.backGroundBox {
                    if backBox == "true" {
                        
                        if let bxCol = consumeActionComp.boxColor {
                            OperationQueue.main.addOperation {
                                self.goThereBtn.backgroundColor = UIColor.init(hexString: bxCol)
                            }
                        }else {
                            OperationQueue.main.addOperation {
                                self.goThereBtn.backgroundColor = UIColor.clear
                            }
                        }
                        
                    }else {
                        OperationQueue.main.addOperation {
                            self.goThereBtn.backgroundColor = UIColor.clear
                        }
                    }
                }
                
                if let rounBox = consumeActionComp.roundedBox {
                    if rounBox == "true" {
                        OperationQueue.main.addOperation {
                            self.goThereBtn.layer.cornerRadius = 10.0
                        }
                    }else {
                        OperationQueue.main.addOperation {
                            self.goThereBtn.layer.cornerRadius = 0.0
                        }
                    }
                }else {
                    OperationQueue.main.addOperation {
                        self.goThereBtn.layer.cornerRadius = 0.0
                    }
                }
                
                if let opact = consumeActionComp.opacity {
                    OperationQueue.main.addOperation {
                        if let n = NumberFormatter().number(from: opact) {
                            let opacty = CGFloat(truncating: n)
                            
                            self.goThereBtn.backgroundColor = self.goThereBtn.backgroundColor?.withAlphaComponent(opacty)
                        }
                    }
                }
                
                if let txt = consumeActionComp.text {
                    OperationQueue.main.addOperation {
                        self.goThereBtn.setTitle(txt, for: .normal)
                    }
                }
                
                if let col = consumeActionComp.color {
                    OperationQueue.main.addOperation {
                        self.goThereBtn.setTitleColor(UIColor.init(hexString: col), for: .normal)
                    }
                }
                
                if let fntSize = consumeActionComp.fontSize {
                    OperationQueue.main.addOperation {
                        if let n = NumberFormatter().number(from: fntSize) {
                            let f = CGFloat(truncating: n)
                            
                            self.goThereBtn.titleLabel?.font = UIFont.systemFont(ofSize: f)
                        }
                    }
                }

            }
            
        } else {
            
            OperationQueue.main.addOperation {
                self.goThereBtn.isHidden = true
            }
            
        }
        
        MultiPageCVCell.currPage = page
        currentPage = page
        if let content = content {
            upButton.isHidden = page == 0
            downButton.isHidden = content.pages.count - 1 == page
        }
        
    }
    
}

extension MultiPageCVCell : UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        selectedRaw = nil
        selectedSection = nil
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        OperationQueue.main.addOperation {
            self.goThereBtn.isHidden = true
        }
        
        var scrollOffset = scrollView.contentOffset.y
        let contentHeight = multiPageCollectionView.contentSize.height - multiPageCollectionView.frame.size.height
        var indexPath : IndexPath?
        if scrollOffset < 0 {
            indexPath = IndexPath(row: 0, section: 0)
        } else if scrollOffset > contentHeight {
            indexPath = IndexPath(row: multiPageCollectionView.numberOfVerticalPages()-1, section: 0)
            scrollOffset = scrollOffset - contentHeight
        }
        if let indexPath = indexPath {
            if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? MultiPageCVCell {
                cell.zoomBackground(0, y: scrollOffset)
            } else if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? ContentImageCVCell {
                cell.zoomBackground(0, y: scrollOffset)
            }else if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? ContentTextCVCell {
                cell.zoomBackground(0, y: scrollOffset)
            }else if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? ContentVideoCVCell {
                cell.zoomBackground(0, y: scrollOffset)
            }else if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? ContentSoundCVCell {
                cell.zoomBackground(0, y: scrollOffset)
            }else if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? ContentYoutubeCVCell {
                cell.zoomBackground(0, y: scrollOffset)
            }else if let cell = multiPageCollectionView.cellForItem(at: indexPath) as? ContentVimeoCVCell {
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
                
                let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                let documentDirectoryPath:String = path[0]
                let fileManager = FileManager()
                                
                var destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath)
                
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
                
            } else {
                print("Failure: %@", error?.localizedDescription ?? "")
                completion("File Download Failed!")
            }
        }
        task.resume()
    }
    
}
