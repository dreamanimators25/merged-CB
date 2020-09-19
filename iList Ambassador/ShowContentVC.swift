//
//  ShowContentVC.swift
//  iList Ambassador
//
//  Created by sameer khan on 09/09/20.
//  Copyright © 2020 iList AB. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AVFoundation
import YouTubePlayer

class ShowContentVC: UIViewController {
    
    @IBOutlet weak var pageBackgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var ContentViewImage: UIImageView!
    @IBOutlet weak var bodyLbl: UILabel!
    @IBOutlet weak var ContentViewSound: UIView!
    @IBOutlet weak var ContentViewVideo: UIView!
    @IBOutlet weak var ContentViewYoutube: YouTubePlayerView!
    @IBOutlet weak var ContentViewVimeo: UIView!
    @IBOutlet weak var goThereBtn: UIButton!
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var soundHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var youtubeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var vimeoHeightConstraint: NSLayoutConstraint!
    
    var content : Content?
    var backgroundVideoView: ContentVideo?
    var background: ContentPageBackground?
    var component0 : ContentPageComponent?
    var component1 : ContentPageComponent?
    
    var vimeoUrl : String?
    var currentPage: Int = 0
    
    var delegate: MultiPageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true

        self.backgroundUpdated(self.background)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.handlePageButtons(self.currentPage)
        
        self.headerLbl.text = component0?.meta?.text
        
        switch component1?.type {
        case .Image:
            
            DispatchQueue.main.async {
                self.imageHeightConstraint.constant = self.view.bounds.height/2
                self.soundHeightConstraint.constant = 0
                self.videoHeightConstraint.constant = 0
                self.youtubeHeightConstraint.constant = 0
                self.vimeoHeightConstraint.constant = 0
            }
            
            let file = component1?.file ?? ""
            if let url = URL(string: file) {
                ContentViewImage.af_setImage(withURL: url)
            }
                        
        case .Text:
          
            DispatchQueue.main.async {
                self.imageHeightConstraint.constant = 0
                self.soundHeightConstraint.constant = 0
                self.videoHeightConstraint.constant = 0
                self.youtubeHeightConstraint.constant = 0
                self.vimeoHeightConstraint.constant = 0
                
                self.bodyLbl.text = self.component1?.meta?.text
            }
                        
        case .Sound:
            
            DispatchQueue.main.async {
                //let wid = 0.75*SCREENSIZE.width
                let wid = SCREENSIZE.width - 20
                let heig = wid*0.95
                self.soundHeightConstraint.constant = heig
                self.imageHeightConstraint.constant = 0
                self.videoHeightConstraint.constant = 0
                self.youtubeHeightConstraint.constant = 0
                self.vimeoHeightConstraint.constant = 0
            
                if let file = self.component1?.file {
                    let width = SCREENSIZE.width - 20
                    let music = ContentMusic(frame: CGRect(x: 0, y: 0,width: width, height: width*0.95), file: file, thumb: self.component1?.thumb, CNTR: CGPoint.init(x: self.ContentViewSound.frame.midX, y: self.ContentViewSound.frame.midY))
                    
                    self.ContentViewSound.addSubview(music)
                }
            }
                        
        case .Video:
            
            DispatchQueue.main.async {
                self.videoHeightConstraint.constant = self.view.bounds.height/2
                self.imageHeightConstraint.constant = 0
                self.soundHeightConstraint.constant = 0
                self.youtubeHeightConstraint.constant = 0
                self.vimeoHeightConstraint.constant = 0
            
                if let file = self.component1?.file {
                    let video = ContentVideo(frame: CGRect(x: 0, y: 0,width: self.view.bounds.width, height: self.view.bounds.height), file: file, inlinePlayer: true)
                    
                    self.ContentViewVideo.addSubview(video)
                }
            }
                        
        case .Embed:
            
            if component1?.embedType == "youtube" {
                
                DispatchQueue.main.async {
                    self.youtubeHeightConstraint.constant = self.view.bounds.height/2
                    self.imageHeightConstraint.constant = 0
                    self.soundHeightConstraint.constant = 0
                    self.videoHeightConstraint.constant = 0
                    self.vimeoHeightConstraint.constant = 0
                }
                
                if let url = component1?.youtubeUrl {
                    let split = url.split(separator: "/")
                    
                    if let embed = split.last {
                        let id = String.init(embed).replacingOccurrences(of: "\"", with: "")
                        self.ContentViewYoutube.loadVideoID(id)
                    }
                }
                                                    
            }else if component1?.embedType == "vimeo" {
                
                DispatchQueue.main.async {
                    self.vimeoHeightConstraint.constant = self.view.bounds.height/2
                    self.imageHeightConstraint.constant = 0
                    self.soundHeightConstraint.constant = 0
                    self.videoHeightConstraint.constant = 0
                    self.youtubeHeightConstraint.constant = 0
                }
                
                if let url = component1?.youtubeUrl {
                    self.vimeoUrl = url
                }
                
            }
            
        default:
            print("Mone")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: IBActions
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playVimeoButtonClicked(_ sender: UIButton) {
        if let vim = loadVimeoPlayer {
            vim(vimeoUrl ?? "")
        }
    }
    
    @IBAction func goThereBtnClicked(_ sender: Any) {
        
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
    
    func handlePageButtons(_ page: Int) {
        
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
                            self.goThereBtn.layer.cornerRadius = 20.0
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
        
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

extension ShowContentVC {
    
    // MARK: - Set Backgrounds
    
    func backgroundUpdated(_ backgroundArg: ContentPageBackground?) {
        guard let background = backgroundArg else {
            pageBackgroundView.backgroundColor = Color.backgroundColorDark()
            return
        }
        
        guard background.order == 0 else {
            return
        }
        
        print("BackGround Type = \(background.type)")
        switch background.type {
        case .Color:
            if let meta = background.meta, let color = meta["color"] as? String {
                pageBackgroundView.backgroundColor = UIColor(hexString: color)
            }
        case .Video:
            if let fileUrl = background.file_url {
                setBackgroundVideo(fileUrl)
                
            } else if let file = background.file {
                setBackgroundVideo(file)
            }
        case .Image:
            if let fileurl = background.file_url {
                setBackgroundImage(fileurl)
            }
            if let file = background.file {
                setBackgroundImage(file)
            }
        }
    }
    
    func addBackgroundSubview(_ view: UIView,subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subview)
        let views = ["subview" : subview]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subview]|", options: .alignAllLastBaseline, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subview]|", options: .alignAllLastBaseline, metrics: nil, views: views))
    }
    
    func setBackgroundImage(_ file: String) {
        if backgroundImageView == nil {
            
            //pageBackgroundView.addSubview(stickerImageView)
            //pageBackgroundView.bringSubviewToFront(stickerImageView)
        }
        
        if let url = URL(string: file) {
            self.backgroundImageView.af_setImage(withURL: url)
        }
        
    }
    
    // MARK: - Video Background
    func setBackgroundVideo(_ file: String) {
        if let backgroundVideoView = backgroundVideoView {
            backgroundVideoView.play(muted: true)
        } else {
            backgroundVideoView = ContentVideo(frame: self.backgroundVideoView?.frame ?? CGRect(), file: file)
            addBackgroundSubview(pageBackgroundView, subview: backgroundVideoView!)
            backgroundVideoView?.play(muted: true)
        }
    }
    
}
