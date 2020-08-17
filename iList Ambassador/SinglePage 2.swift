//
//  SinglePage.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-07-20.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import AVFoundation
import YouTubePlayer

protocol SinglePageDelegate {
    func showLink(_ link: String, contentId: Int)
    func showCode(_ code: String, asQR: Bool)
    func showContentConsumedWithAmbassadorshipContent(_ contentTitle: String)
    func showShare(_ contentId: Int)
    func showShareOutbound(_ contentId: Int)
    func showErrorMessage(_ message: String)
    func getBackgroundForSharing(_ image: ContentFillImage)
    func showNewLink(link: String)
    func imageLoaded(image: UIImage)
    func showVimeoPlayer(_ link: String)
}

struct ImageIndex {
    var hor = 0
    var ver = 0
    
    var image: UIImage?
}

var loadVimeoPlayer : ((_ url:String)-> (Void))?


class SinglePage: UICollectionViewCell {
    
    // MARK: - Views
    var vimeoUrl : String?
    
    var delegate: SinglePageDelegate?
    
    @IBOutlet weak var pageBackgroundView: UIView!
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var shareButton: BrandButton!
    @IBOutlet weak var outboundShareButton: BrandButton!
    
    static var imageShare: UIImage?

    // MARK: - Backgrounds
    
    var backgroundImageView: ContentFillImage? {
        didSet {
            print("Updated background")
            BGDelegate?.setShareImage(backgroundImageView!)
            
        }
    }
    var backgroundVideoView: ContentVideo?
    
    // MARK: - Component Views
    
    var contentButton: ContentButton?
    var componentViews = [ContentView]()
    var componentConstraints = [NSLayoutConstraint]()
    
    // MARK: - Load Content
    var singleContent: Content?
    var contentId: Int?
    var contentTitle: String?
    var BGDelegate: backgroundDelegate?
    var background: ContentPageBackground? {
        didSet {
            
            backgroundUpdated(background)
            
        }
    }
    
    var sharableImageView: UIImageView?
    
    var components: [ContentPageComponent]? {
        didSet { componentsUpdated(components) }
    }
    
    var consumeAction: ConsumeAction?
    var isShareable: Bool = false {
        didSet {
            if isShareable {
                if shareButton != nil {
                    shareButton.isHidden = false
                }
            } else {
                if shareButton != nil {
                    shareButton.isHidden = true
                }
            }
        }
    }
    var currentPage: Int?
    var currentContentSubPage: Int?
    
    @IBOutlet weak var PageHeightConstraint: NSLayoutConstraint!
    
    // MARK: - life cycle 
    
    override func prepareForReuse() {
        super.prepareForReuse()
        removeButton()
        componentViews.forEach {
            $0.prepareForReuse()
            $0.view.removeFromSuperview()
        }
        componentViews = []
        
        backgroundImageView?.af_cancelImageRequest()
        backgroundImageView?.image = nil
        background = nil
        
        contentId = nil
        contentTitle = nil
        components = nil
        consumeAction = nil
        isShareable = false
        
        pauseMedia()
        
        loadVimeoPlayer = { vimURL in
            self.delegate?.showVimeoPlayer(vimURL)
        }
    }
    
    func configure(with content: Content, consumeAction: ConsumeAction?, shareable: Bool, pageIndex: Int) {
        singleContent = content
        contentId = content.id
        contentTitle = content.title
        isShareable = shareable
        //isShareable = shareable
        self.consumeAction = consumeAction
        
        if content.pages.count > 0 && pageIndex < content.pages.count  {
            let page = content.pages[pageIndex]
            
            print("background = \(background?.file), \(background?.file_url)")
            if let pageBackground = page.backgrounds {
                background = pageBackground
                
            }
            components = page.components
        }
    }
    
    // MARK: - Actions
    
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

extension SinglePage {
    
    // MARK - Set Components
    
    func componentsUpdated(_ components: [ContentPageComponent]?) {
        print("aa = \(singleContent?.identity)")
        guard let components = components else {
            return
        }
        
        
        //for i in 0..<components.count {
        for i in 0..<2 {
            let component = components[i]
        
            switch component.type {
            case .Image:
                createImage(component)
            case .Text:
                createText(component)
            case .Video:
                createVideo(component)
            case .Sound:
                createSound(component)
            case .Embed:
                
                if component.embedType == "youtube" {
                    createEmbed(component)
                    //print("embed = \(component.youtubeUrl)")
                }else if component.embedType == "vimeo" {
                    //delegate?.showVimeoPlayer(component.youtubeUrl ?? "")
                    self.createEmbedVimeo(component)
                    //print("embed = \(component.youtubeUrl)")
                }
                
            }
        }
        //createButton(consumeAction)
        layoutComponentViews()
    }

    
    func createImage(_ component: ContentPageComponent) {
        if let file = component.file {
            /*
            let imageView = ContentImage(frame: CGRect.zero)
            imageView.setImageFromStringAndMargin(file, horizontalMarginPercent: component.marginHorizontalPercent)
            imageView.delegate = self
            imageView.marginEdgePercentage = component.marginEdgePercentage
            imageView.bottomMarginPercent = component.marginBottomPercent
            componentViews.append(imageView)
            
            sharableImageView = imageView
            */ //old code from client
            
            //*
            let imageView = ContentImage(frame: CGRect.zero)
            imageView.setImageFromStringAndMargin(file, horizontalMarginPercent: 0)
            imageView.delegate = self
            //imageView.marginEdgePercentage = 0
            //imageView.bottomMarginPercent = 20
            componentViews.append(imageView)
            
            sharableImageView = imageView
            //*/
            
        }
    }
    
    func createText(_ component: ContentPageComponent) {
        if let meta = component.meta {
            //let label = ContentText(meta: meta, bottomMarginPercent: component.marginBottomPercent, horizontalMarginPercent: component.marginHorizontalPercent)
            //label.marginEdgePercentage = component.marginEdgePercentage
            //old code from client
            
            
            if meta.text == "Vimeo" {
                var margin = 0.0
                switch UIScreen.main.nativeBounds.height {
                //case 960:
                    //return .iPhone4
                case 1136:
                    margin = 5.0
                    //return .iPhone5
                case 1334:
                    margin = 5.0
                    //return .iPhone6
                case 2208, 1920:
                    margin = 10.0
                    //return .iPhone6Plus
                case 2436:
                    margin = 20.0
                    //return .iPhoneX
                default:
                    margin = 20.0
                    //return .Unknown
                }
                
                
                let label = ContentText(meta: meta, bottomMarginPercent: CGFloat(margin), horizontalMarginPercent: 10)
                label.marginEdgePercentage = 0
                
                componentViews.append(label)
                
            }else {
                var margin = 0.0
                switch UIScreen.main.nativeBounds.height {
                //case 960:
                    //return .iPhone4
                case 1136:
                    margin = 30.0
                    //return .iPhone5
                case 1334:
                    margin = 40.0
                    //return .iPhone6
                case 2208, 1920:
                    margin = 50.0
                    //return .iPhone6Plus
                case 2436:
                    margin = 60.0
                    //return .iPhoneX
                default:
                    margin = 60.0
                    //return .Unknown
                }
                
                
                let label = ContentText(meta: meta, bottomMarginPercent: CGFloat(margin), horizontalMarginPercent: 0)
                label.marginEdgePercentage = 0
                
                componentViews.append(label)
            }
            
        }
    }
    
    func createVideo(_ component: ContentPageComponent) {
        if let file = component.file {
            let screenWidht = SCREENSIZE.width
            let width = screenWidht-((component.marginHorizontalPercent/100 * 2) * screenWidht)
            let video = ContentVideo(frame: CGRect(x: 0, y: 0,width: width, height: width*0.8), file: file, inlinePlayer: true)
            video.marginEdgePercentage = component.marginEdgePercentage
            video.bottomMarginPercent = component.marginBottomPercent
            video.horizontalMarginPercent = component.marginHorizontalPercent
            componentViews.append(video)
        }
    }
    
    func createEmbed(_ component: ContentPageComponent) {
        if let url = component.youtubeUrl {
            let screenWidht = SCREENSIZE.width
            let embed = ContentEmbed(frame: CGRect(x: 0, y: 0,width: screenWidht, height: screenWidht * 0.8), url: url,CNTR: CGPoint.init(x: self.contentView.frame.midX, y: self.contentView.frame.midY))
            componentViews.append(embed)
        }
    }
    
    func createEmbedVimeo(_ component: ContentPageComponent) {
        if let url = component.youtubeUrl {
            
            let screenWidht = SCREENSIZE.width
            
            let embed = ContentEmbedVimeo(frame: CGRect(x: 0, y: 0,width: screenWidht, height: screenWidht * 0.8), url: url,CNTR: CGPoint.init(x: self.contentView.frame.midX, y: self.contentView.frame.midY))
            
            componentViews.append(embed)
            
        }
    }
    
    @objc func playVimeo() {
        delegate?.showVimeoPlayer(vimeoUrl ?? "")
    }
    
    func createSound(_ component: ContentPageComponent) {
        if let file = component.file {
            let width = 0.75*SCREENSIZE.width
            let music = ContentMusic(frame: CGRect(x: 0, y: 0,width: width, height: width*0.95), file: file, thumb: component.thumb)
            music.marginEdgePercentage = component.marginEdgePercentage
            music.bottomMarginPercent = component.marginBottomPercent
            componentViews.append(music)
        }
    }
    
    func removeButton() {
        contentButton?.removeFromSuperview()
        contentButton = nil
    }
    /*
    func createButton(_ consumeAction: ConsumeAction?) {
        // Remove before creating new button
        removeButton()
        
        guard let consumeAction = consumeAction else { return }

        let button = ContentButton(customTitle: consumeAction.contentButtonTitle)
        button.touchUpInsideBlock = { [weak self] in
            self?.didTapConsumableButton(button, action: consumeAction)
        }
        contentButton = button
    }
    */
}

extension SinglePage {
    
    // MARK: - Layout Component Views
    
    func layoutComponentViews() {
        var veritcalVisualString = "V:"
        var views = [String : UIView]()
        var verticalMetrics = [String : CGFloat]()
        let screenHeight = pageView.frame.size.height
        let screenWidht = SCREENSIZE.width
        var height: CGFloat = 0.0
        pageView.removeConstraints(componentConstraints)
        componentConstraints.removeAll()
        for i in 0..<componentViews.count {
            
            let component = componentViews[i]
            let view = component.view
            pageView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            
            let left = ((screenWidht - component.width) * (component.horizontalMarginPercent/100))
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[view]-left-|", options: [],metrics: ["left":left],views: ["view":view])
            componentConstraints += horizontalConstraints
            let metricsName = "bottom\(i)"
            var viewString = "view\(i)"
            
            views[viewString] = view
            viewString += "(\(component.height))"
            
            var vertMargin = component.bottomMarginPercent
            if vertMargin == 0 {
                vertMargin = component.marginEdgePercentage*10
            }
            
            let bottom = (screenHeight - component.height) * (component.bottomMarginPercent/100)
            
            height += bottom + component.height
            
            verticalMetrics[metricsName] = bottom
            if i != 0 {
                veritcalVisualString += "-"
            }
            veritcalVisualString += "[\(viewString)]-\(metricsName)"
        }
        if componentViews.count > 0 {
            veritcalVisualString += "-|"
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: veritcalVisualString, options: [], metrics: verticalMetrics, views: views)
            componentConstraints += verticalConstraints
            pageView.addConstraints(componentConstraints)
        }
        
        if let contentButton = contentButton {
            contentView.addSubview(contentButton)
            contentButton.translatesAutoresizingMaskIntoConstraints = false
            let views = ["contentButton":contentButton]
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentButton]|", options: .alignAllLastBaseline, metrics: nil, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[contentButton(==60)]|", options: .alignAllLastBaseline, metrics: nil, views: views))
        }
        
        PageHeightConstraint.constant = height
        layoutIfNeeded()
    }
    
}

extension SinglePage {
    /*
    // MARK: - Content Button delegates
    func didTapConsumableButton(_ sender: ContentButton, action: ConsumeAction) {
        if let id = contentId {
            sender.startLoading()
            ContentManager.sharedInstance.consumeAmbassadorshipContent(id, completion: {
                (contentConsumeData, error) in
                sender.stopLoading()
                guard contentConsumeData != nil else {
                    DispatchQueue.main.async(execute: {
                        self.delegate?.showErrorMessage(NSLocalizedString("CONTENT_NOT_FOUND_ALERT", comment: ""))
                    })
                    return
                }
                switch action {
                case .link, .reusable:
                    if let consumeData = contentConsumeData!.consumeData {
                        var newUrl = "http://\(consumeData)"
                        if consumeData.range(of: "http") != nil {
                            newUrl = consumeData
                        }
                        DispatchQueue.main.async(execute: {
                            self.delegate?.showLink(newUrl, contentId: id)
                        })
                    }
                case .code:
                    if let consumeData = contentConsumeData!.consumeData {
                        DispatchQueue.main.async(execute: {
                            self.delegate?.showCode(consumeData, asQR: contentConsumeData!.showAsQr)
                        })
                    }
                case .onlyConsumable:
                    DispatchQueue.main.async(execute: {
                        self.delegate?.showContentConsumedWithAmbassadorshipContent(self.contentTitle ?? "")
                    })
                }
            })
        }
    }
    */
    @IBAction func didTapShareButton(_ sender: AnyObject) {
        share(sender)
    }
    
    @IBAction func didTapOutboundShareButton(_ sender: AnyObject) {
        shareOutbound(sender)
    }
    
    func share(_ sender: AnyObject) {
        if let id = contentId {
            delegate?.showShare(id)
        }
    }
    
    func shareOutbound(_ sender: AnyObject) {
        
        if let id = contentId {
            delegate?.showShareOutbound(id)
        }
    }
}

extension SinglePage {
    
    // MARK: - Set Backgrounds
    
    func backgroundUpdated(_ backgroundArg: ContentPageBackground?) {
        guard let background = backgroundArg else {
            pageBackgroundView.backgroundColor = Color.backgroundColorDark()
            return
        }
        
        guard background.order == 0 else {
            return
        }
        
        print("tiiii = \(background.type)")
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
            backgroundImageView = ContentFillImage(frame: frame)
            addBackgroundSubview(pageBackgroundView, subview: backgroundImageView!)
        }
        backgroundImageView?.setImageFromString(file)
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

extension SinglePage: ContentImageDelegate {
    func imageLoaded(image: UIImage) {
        layoutComponentViews()

        SinglePage.imageShare = image
        delegate?.imageLoaded(image: image)
    }
}
