//
//  ContentVideoCVCell.swift
//  AppIn
//
//  Created by sameer khan on 23/07/20.
//  Copyright © 2020 Sameer khan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ContentVideoCVCell: UICollectionViewCell {

    @IBOutlet weak var contentVideoView: UIView!
    @IBOutlet weak var pageBackgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var backgroundVideoView: ContentVideo?
    var stickerImageView = UIImageView()
    var componentViews = [ContentView]()
    
    
    //MultiLink & InAppLink
    var arrContentID = [String]()
    var arrPageID = [String]()
    var click = true
    var inAppLinkBaseView = UIView()
    var multiLinkBaseView = UIStackView()
    var base1 = UIView()
    var base2 = UIView()
    var base3 = UIView()
    var link1 = String()
    var link2 = String()
    var link3 = String()
    
    var delegate: MultiPageDelegate?
    
    var pageNo : Int? {
        didSet {
            
            if let page = pageNo {
                
                print(page)
                
                if content?.pages[page].consumeAction == 9 {
                    print("MultiLink")
                    
                    OperationQueue.main.addOperation {
                        self.addMultiLinkOnView(page: (self.content?.pages[page])!)
                    }
                    
                }
                
                if content?.pages[page].consumeAction == 10 {
                    print("inAppLink")
                    
                    if let isIdentity = content?.pages[page].identity {
                        print("connect = \(isIdentity)")
                        
                        let strArray = isIdentity.components(separatedBy: ",")
                        for (index,item) in strArray.enumerated() {
                            if index % 2 == 0 {
                                if item != "" {
                                    self.arrContentID.append(item)
                                }
                            }else {
                                if item != "" {
                                    self.arrPageID.append(item)
                                }
                            }
                        }
                    }
                    
                    OperationQueue.main.addOperation {
                        self.addInAppLinkOnView()
                    }
                    
                }
            }
        }
    }
    
    var content:Content? {
        didSet {
            
            if (content != nil) {
                OperationQueue.main.addOperation {
                    self.inAppLinkBaseView.removeFromSuperview()
                    self.contentView.superview?.willRemoveSubview(self.inAppLinkBaseView)
                    
                    self.multiLinkBaseView.removeFromSuperview()
                    self.contentView.superview?.willRemoveSubview(self.multiLinkBaseView)
                    
                    self.base1.removeFromSuperview()
                    self.contentView.superview?.willRemoveSubview(self.base1)
                    self.base2.removeFromSuperview()
                    self.contentView.superview?.willRemoveSubview(self.base2)
                    self.base3.removeFromSuperview()
                    self.contentView.superview?.willRemoveSubview(self.base3)
                }
            }
            
        }
    }
    
    
    var background: ContentPageBackground? {
        didSet {
            self.stickerImageView.image = nil
            self.stickerImageView.removeFromSuperview()
            
            backgroundUpdated(background)
        }
    }
    
    var stickerURL: String? {
        didSet {
            setStickerFromString(stickerURL ?? "")
        }
    }

    var component : ContentPageComponent? {
        didSet {
            if let file = component?.file {
                DispatchQueue.main.async {
                    let video = ContentVideo(frame: CGRect(x: 0, y: 0,width: self.contentVideoView.bounds.width, height: self.contentVideoView.bounds.height), file: file, inlinePlayer: true)
                    self.componentViews.append(video)
                    
                    self.contentVideoView.addSubview(video)
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func pauseMedia() {
        backgroundVideoView?.reset()
        for component in componentViews {
            if let component = component as? ContentMusic {
                component.reset()
            } else if let component = component as? ContentVideo {
                component.reset()
            }
        }
    }

}

extension ContentVideoCVCell {
    
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
    
    // MARK: - Image Background
    func setBackgroundImage(_ file: String) {
        if backgroundImageView == nil {
            
            //pageBackgroundView.addSubview(stickerImageView)
            //pageBackgroundView.bringSubviewToFront(stickerImageView)
        }
        
        if let url = URL(string: file) {
            self.backgroundImageView.af_setImage(withURL: url)
        }
        
    }
    
    func setStickerFromString(_ urlString: String) {
        if let url = URL(string: urlString) {
                        
            stickerImageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.crossDissolve(0.5), runImageTransitionIfCached: true, completion: { (response: DataResponse<UIImage>) in
                
                self.stickerImageView.frame = CGRect.init(x: 0, y: self.contentView.frame.size.height - SCREENSIZE.width/3, width: SCREENSIZE.width, height: SCREENSIZE.width/3)
                self.stickerImageView.contentMode = .scaleToFill
                self.stickerImageView.clipsToBounds = true
                
                self.backgroundImageView.addSubview(self.stickerImageView)
                self.backgroundImageView.bringSubviewToFront(self.stickerImageView)
            })
            
        }
    }
    
    // MARK: - Video Background
    func setBackgroundVideo(_ file: String) {
        if let backgroundVideoView = backgroundVideoView {
            backgroundVideoView.play(muted: true)
        } else {
            backgroundVideoView = ContentVideo(frame: frame, file: file)
            addBackgroundSubview(pageBackgroundView, subview: backgroundVideoView!)
            backgroundVideoView?.play(muted: true)
        }
    }
    
    // MARK: - Background Zoom
    func zoomBackground(_ x: CGFloat, y: CGFloat) {
        if let pageBackgroundView = pageBackgroundView {
            let width = bounds.width
            let scale = (width + 2.0*abs(0.5*(x+y)))/width
            pageBackgroundView.transform = CGAffineTransform.identity.translatedBy(x: x, y: y)
            pageBackgroundView.transform = pageBackgroundView.transform.scaledBy(x: scale, y: scale)
        }
    }
    
}

extension ContentVideoCVCell {
    
    func addMultiLinkOnView(page : ContentPage) {
        
        self.multiLinkBaseView.removeFromSuperview()
        self.contentView.superview?.willRemoveSubview(multiLinkBaseView)
        self.base1.removeFromSuperview()
        self.contentView.superview?.willRemoveSubview(base1)
        self.base2.removeFromSuperview()
        self.contentView.superview?.willRemoveSubview(base2)
        self.base3.removeFromSuperview()
        self.contentView.superview?.willRemoveSubview(base3)
        
        
        
        multiLinkBaseView = UIStackView.init(frame: CGRect.init(x: 10, y: (self.contentView.frame.height * 20)/100, width: self.contentView.frame.size.width - 20, height: ((self.contentView.frame.width/4)*3.2)))
        
        multiLinkBaseView.axis = .vertical
        multiLinkBaseView.distribution = .fillEqually
        multiLinkBaseView.alignment = .fill
        multiLinkBaseView.spacing = 15.0
        
        
        base1 = UIView.init(frame: CGRect.init(x: 20, y: 10, width: (self.contentView.frame.width - 40), height: (self.contentView.frame.width/4)))
        let img1 = UIImageView.init(frame: CGRect.init(x: 20, y: 15, width: (base1.frame.width/3 - 50), height: (base1.frame.width/3 - 50)))
        let lbl1 = UILabel.init(frame: CGRect.init(x: img1.frame.origin.x + img1.frame.size.width + 10, y: base1.frame.size.height/4 - 10, width: base1.frame.size.width/2 + 80, height: img1.frame.size.height))
        lbl1.lineBreakMode = NSLineBreakMode.byWordWrapping
        lbl1.numberOfLines = 0
        
        
        lbl1.font = lbl1.font.withSize(20)
        if let txt = page.components[3].meta?.text {
            lbl1.text = txt
        }
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
        }
        
        
        let btn1 = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: base1.frame.size.width, height: base1.frame.size.height))
        btn1.tag = 1
        btn1.addTarget(self, action: #selector(ContentTextCVCell.btnClickedMultiLink(_:)), for: .touchUpInside)
        btn1.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        
        base2 = UIView.init(frame: CGRect.init(x: 20, y: base1.frame.origin.y + base1.frame.size.height + 15, width: (self.contentView.frame.width - 40), height: (self.contentView.frame.width/4)))
        
        let img2 = UIImageView.init(frame: CGRect.init(x: 20, y: 15, width: (base2.frame.width/3 - 50), height: (base2.frame.width/3 - 50)))
        let lbl2 = UILabel.init(frame: CGRect.init(x: img2.frame.origin.x + img2.frame.size.width + 10, y: base2.frame.size.height/4 - 10, width: base2.frame.size.width/2 + 80, height: img2.frame.size.height))
        lbl2.lineBreakMode = NSLineBreakMode.byWordWrapping
        lbl2.numberOfLines = 0
        
        
        lbl2.font = lbl2.font.withSize(20)
        if let txt = page.components[5].meta?.text {
            lbl2.text = txt
        }
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
        }
        
        let btn2 = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: base2.frame.size.width, height: base2.frame.size.height))
        btn2.tag = 2
        btn2.addTarget(self, action: #selector(ContentTextCVCell.btnClickedMultiLink(_:)), for: .touchUpInside)
        btn2.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        
        base3 = UIView.init(frame: CGRect.init(x: 20, y: base2.frame.origin.y + base2.frame.size.height + 15, width: (self.contentView.frame.width - 40), height: (self.contentView.frame.width/4)))
        
        let img3 = UIImageView.init(frame: CGRect.init(x: 20, y: 15, width: (base3.frame.width/3 - 50), height: (base3.frame.width/3 - 50)))
        let lbl3 = UILabel.init(frame: CGRect.init(x: img3.frame.origin.x + img3.frame.size.width + 10, y: base3.frame.size.height/4 - 10, width: base3.frame.size.width/2 + 80, height: img3.frame.size.height))
        lbl3.lineBreakMode = NSLineBreakMode.byWordWrapping
        lbl3.numberOfLines = 0
        
        
        lbl3.font = lbl3.font.withSize(20)
        if let txt = page.components[7].meta?.text {
            lbl3.text = txt
        }
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
        }
        
        let btn3 = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: base3.frame.size.width, height: base3.frame.size.height))
        btn3.tag = 3
        btn3.addTarget(self, action: #selector(ContentTextCVCell.btnClickedMultiLink(_:)), for: .touchUpInside)
        btn3.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        
        base1.addSubview(img1)
        base1.addSubview(lbl1)
        base1.addSubview(btn1)
        base1.backgroundColor = #colorLiteral(red: 0.4117647059, green: 0.4156862745, blue: 0.4274509804, alpha: 1)
        self.multiLinkBaseView.addArrangedSubview(base1)
        
        base2.addSubview(img2)
        base2.addSubview(lbl2)
        base2.addSubview(btn2)
        base2.backgroundColor = #colorLiteral(red: 0.4117647059, green: 0.4156862745, blue: 0.4274509804, alpha: 1)
        self.multiLinkBaseView.addArrangedSubview(base2)
        
        base3.addSubview(img3)
        base3.addSubview(lbl3)
        base3.addSubview(btn3)
        base3.backgroundColor = #colorLiteral(red: 0.4117647059, green: 0.4156862745, blue: 0.4274509804, alpha: 1)
        self.multiLinkBaseView.addArrangedSubview(base3)
        
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
        
    }
    
    @objc func btnClickedMultiLink(_ sender : UIButton) {
        
        switch sender.tag {
        case 1:
            DispatchQueue.main.async {
                self.delegate?.openLinkInAppInWebView(link: self.link1)
            }
        case 2:
            DispatchQueue.main.async {
                self.delegate?.openLinkInAppInWebView(link: self.link2)
            }
        default:
            DispatchQueue.main.async {
                self.delegate?.openLinkInAppInWebView(link: self.link3)
            }
        }
    
    }
    
    func addInAppLinkOnView() {
        
        //To handle case of MultiLink & InAppLink
        self.inAppLinkBaseView.removeFromSuperview()
        self.contentView.superview?.willRemoveSubview(inAppLinkBaseView)
        
        
        
        inAppLinkBaseView = UIView.init(frame: CGRect.init(x: 10, y: 10, width: self.contentView.frame.size.width - 20, height: self.contentView.frame.size.height - 20))
        
        let btn1 = UIButton.init(frame: CGRect.init(x: 20, y: (self.contentView.frame.height * 17)/100, width: self.contentView.frame.size.width - 40, height: (self.contentView.frame.height * 12)/100))
        btn1.tag = 0
        btn1.addTarget(self, action: #selector(ContentTextCVCell.btnClickedInAppLink(_:)), for: .touchUpInside)
        btn1.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        btn1.backgroundColor = #colorLiteral(red: 0.1581287384, green: 0.6885935664, blue: 0.237049073, alpha: 1)
        
        let btn2 = UIButton.init(frame: CGRect.init(x: 20, y: btn1.frame.origin.y + btn1.frame.size.height + 20, width: self.contentView.frame.size.width - 40, height: (self.contentView.frame.height * 12)/100))
        btn2.tag = 1
        btn2.addTarget(self, action: #selector(ContentTextCVCell.btnClickedInAppLink(_:)), for: .touchUpInside)
        btn2.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        btn2.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        
        let btn3 = UIButton.init(frame: CGRect.init(x: 20, y: btn2.frame.origin.y + btn2.frame.size.height + 20, width: self.contentView.frame.size.width - 40, height: (self.contentView.frame.height * 12)/100))
        btn3.tag = 2
        btn3.addTarget(self, action: #selector(ContentTextCVCell.btnClickedInAppLink(_:)), for: .touchUpInside)
        btn3.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        btn3.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        
        let btn4 = UIButton.init(frame: CGRect.init(x: 20, y: btn3.frame.origin.y + btn3.frame.size.height + 20, width: self.contentView.frame.size.width - 40, height: (self.contentView.frame.height * 12)/100))
        btn4.tag = 3
        btn4.addTarget(self, action: #selector(ContentTextCVCell.btnClickedInAppLink(_:)), for: .touchUpInside)
        btn4.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        btn4.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        
        let btn5 = UIButton.init(frame: CGRect.init(x: 20, y: btn4.frame.origin.y + btn4.frame.size.height + 20, width: self.contentView.frame.size.width - 40, height: (self.contentView.frame.height * 12)/100))
        btn5.tag = 4
        btn5.addTarget(self, action: #selector(ContentTextCVCell.btnClickedInAppLink(_:)), for: .touchUpInside)
        btn5.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        btn5.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        
        inAppLinkBaseView.addSubview(btn1)
        inAppLinkBaseView.addSubview(btn2)
        inAppLinkBaseView.addSubview(btn3)
        inAppLinkBaseView.addSubview(btn4)
        inAppLinkBaseView.addSubview(btn5)
        
        //self.contentView.superview?.addSubview(baseView)
        self.addSubview(inAppLinkBaseView)
    }
    
    @objc func btnClickedInAppLink(_ sender : UIButton) {
        
        guard arrContentID.count > sender.tag else {
            return
        }
        
        guard arrPageID.count > sender.tag else {
            return
        }
        
        let contId = arrContentID[sender.tag]
        let pageId = arrPageID[sender.tag]
        
        let indexOfContentID = actualContents.firstIndex(where: { $0.id == Int(contId) })
        print(indexOfContentID ?? 0)
        
        let indexOfPageID = self.content?.pages.firstIndex(where: { $0.id == Int(pageId) })
        print(indexOfPageID ?? 0)
        
        if let load = loadCollectionView {
            load(IndexPath.init(row: indexOfContentID ?? 0, section: indexOfPageID ?? 0))
        }
        
    }
}
