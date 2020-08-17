//
//  ContentViewCollectionViewCell.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 10/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

protocol ContentPageComponentProtocol {
    func reset()
    func view() -> UIView
    func updateWithHeightConstraint(heightConstraint: NSLayoutConstraint)
    func updateHeightForComponentWithWidth(width: CGFloat)
    func prefferedMargin() -> CGFloat
    
    func prepareForReuse()
}

protocol AmbassadorshipContentUseProtocol {
    func showLink(link: String, ambassadorshipContent: AmbassadorshipContent)
    func showCode(code: String, asQR: Bool, ambassadorshipContent: AmbassadorshipContent)
    func showContentConsumedWithAmbassadorshipContent(ambassadorshipContent: AmbassadorshipContent)
    func showErrorMessage(message: String)
}

class ContentPageCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "ContentPageCollectionViewCell"
    
    var delegate: AmbassadorshipContentUseProtocol?
    
    // MARK: Views
    lazy var backgroundMediaView: ContentBackgroundMediaView = {
        let backgroundMediaView = ContentBackgroundMediaView(frame: SCREENSIZE)
        backgroundMediaView.translatesAutoresizingMaskIntoConstraints = false
        backgroundMediaView.clipsToBounds = false
        return backgroundMediaView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: SCREENSIZE)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    lazy var scrollViewContainerView: UIView = {
        let containerView = UIView(frame: SCREENSIZE)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.clearColor()
        return containerView
    }()
    
    // MARK: Constraints
    var scrollViewContainerViewCenterYConstraint: NSLayoutConstraint?
    
    // MARK: Data
    var pageComponents: [ContentPageComponentProtocol] = []
    
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
        backgroundMediaView.prepareForReuse()
        pageComponents.forEach({
            $0.prepareForReuse()
            $0.view().removeFromSuperview()
        })
        pageComponents = []
    }
    
    private func setup() {
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        
        clipsToBounds = false
        contentView.clipsToBounds = false
        
        contentView.addSubview(backgroundMediaView)
        contentView.addSubview(scrollView)
        scrollView.addSubview(scrollViewContainerView)
        
        let views = [
            "backgroundMediaView" : backgroundMediaView,
            "scrollView" : scrollView,
            "scrollViewContainerView" : scrollViewContainerView
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[backgroundMediaView]|", options: .AlignAllBaseline, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundMediaView]|", options: .AlignAllBaseline, metrics: nil, views: views))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: .AlignAllBaseline, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: .AlignAllBaseline, metrics: nil, views: views))

        contentView.addConstraint(NSLayoutConstraint(item: scrollViewContainerView, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1.0, constant: -20.0))
        contentView.addConstraint(NSLayoutConstraint(item: scrollViewContainerView, attribute: .Height, relatedBy: .LessThanOrEqual , toItem: scrollView, attribute: .Height, multiplier: 0.8, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: scrollViewContainerView, attribute: .CenterX, relatedBy: .Equal, toItem: scrollView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        let centerY = NSLayoutConstraint(item: scrollViewContainerView, attribute: .CenterY, relatedBy: .Equal, toItem: scrollView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        scrollViewContainerViewCenterYConstraint = centerY
        contentView.addConstraint(centerY)
    }
    
    // MARK: - Animation
    
    func zoomBackgroundWithOffset(offset: CGFloat) {
        let width = CGRectGetWidth(bounds)
        let scale = (width + 2.0*abs(0.5*offset))/width
        backgroundMediaView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, offset)
        backgroundMediaView.transform = CGAffineTransformScale(backgroundMediaView.transform, scale, scale)
    }
    
    // MARK: - Content view
    
    func updateWithContent(ambassadorshipContent: AmbassadorshipContent, contentPage: ContentPage, contentPageIndex: Int) {
        let isLastPage = (contentPageIndex == ambassadorshipContent.content.pages.count-1)
        
        var componentViews = [ContentPageComponentProtocol]()
        for (componentIndex, component) in contentPage.components.enumerate() {
            if component.type == .Text {
                /*if let metaDict = component.meta, let text = metaDict["text"] as? String {
                    var fontSize: CGFloat = 16.0
                    if let metaDataFontSize = metaDict["font_size"] as? String {
                        fontSize = CGFloat(NSString(string: metaDataFontSize).floatValue)
                    }
                    var color = UIColor.blackColor()
                    if let metaDataColor = metaDict["color"] as? String {
                        color = UIColor(hexString: metaDataColor)
                    }
                    let contentPageComponentTextView = ContentPageComponentTextView(text: text, font: Font.normalFont(fontSize), color: color)
                    contentPageComponentTextView.prefferdMargin = CGFloat(component.marginEdgePercentage)
                    componentViews.append(contentPageComponentTextView)
                }*/
            } else if component.type == .Image {
                if let imageUrlString = component.file {
                    let contentPageComponentImageView = ContentPageComponentImageView(imageUrlString: imageUrlString)
                    //contentPageComponentImageView.prefferdMargin = CGFloat(component.marginEdgePercentage)
                    componentViews.append(contentPageComponentImageView)
                }
            } else if component.type == .Video {
                if let videoUrlString = component.file {
                    let contentPageComponentVideoView = ContentPageComponentVideoView(videoUrlString: videoUrlString)
                    //contentPageComponentVideoView.prefferdMargin = CGFloat(component.marginEdgePercentage)
                    componentViews.append(contentPageComponentVideoView)
                }
            }
            
        }
        
        if isLastPage {
            // Last page in content
            if ambassadorshipContent.content.claimable {
                
                let title: String = {
                    switch ambassadorshipContent.content.consumeAction {
                    case .Code:
                        return NSLocalizedString("USE", comment: "")
                    case .Link:
                        return NSLocalizedString("OPEN", comment: "")
                    case .OnlyConsumable:
                        return NSLocalizedString("USE", comment: "")
                    }
                }()
                
                let button = ContentPageComponentButton(customTitle: title)
                button.touchUpInsideBlock = {
                    self.didTapUseContentButton(button, ambassadorshipContentId: ambassadorshipContent.id)
                }
                componentViews.append(button)
            }
            
            // We add the share button in version 3.1?
            //                if ambassadorshipContent.content.shareable {
            //                    let button = ContentPageComponentButton(customTitle: NSLocalizedString("SHARE", comment: ""))
            //                    button.touchUpInsideBlock = {
            //                        self.didTapShareContentButton(button, ambassadorshipContentId: ambassadorshipContent.id)
            //                    }
            //                    componentViews.append(button)
            //                }
        }
        
        pageComponents = componentViews
        layoutComponents()

        NSNotificationCenter.defaultCenter().postNotificationName("contentLoaded", object: nil)
    }
    
    func updateWithContentPageBackground(contentPageBackground: ContentPageBackground?) {
        if let contentPageBackground = contentPageBackground {
            switch contentPageBackground.type {
            case .Color:
                if let metaDict = contentPageBackground.meta, let colorString = metaDict["color"] as? String {
                    backgroundMediaView.updateWithColorString(colorString)
                } else {
                    backgroundMediaView.updateWithColor(Color.backgroundColorDark())
                }
            case .Image:
                if let contentPageBackgroundFileUrl = contentPageBackground.file {
                    backgroundMediaView.updateWithImageUrl(contentPageBackgroundFileUrl)
                } else {
                    backgroundMediaView.updateWithColor(Color.backgroundColorDark())
                }
            case .Video:
                if let video = contentPageBackground.video {
                    //backgroundMediaView.updateWithVideo(video)
                } else {
                    backgroundMediaView.updateWithColor(Color.backgroundColorDark())
                }
            }
        } else {
            backgroundMediaView.updateWithTransparentBackground()
        }
    }

    private func layoutComponents() {
        if pageComponents.count == 0 {
            return
        }
        var previous:UIView?
        for (index, component) in pageComponents.enumerate() {
            let view = component.view()
            scrollViewContainerView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            if let previous = previous {
                scrollViewContainerView.addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: previous, attribute: .Bottom, multiplier: 1.0, constant: 20.0))
            } else {
                scrollViewContainerView.addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: scrollViewContainerView, attribute: .Top, multiplier: 1.0, constant: 0.0))
            }
            scrollViewContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-12-[view]-12-|", options: .AlignAllCenterX, metrics: nil, views: ["view":view]))
            if index == pageComponents.count-1 {
                scrollViewContainerView.addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: scrollViewContainerView, attribute: .Bottom, multiplier: 1.0, constant: 0))
            }
            previous = view
        }
        

        

        /*var previousView: UIView?
        scrollViewContainerView.backgroundColor = UIColor.redColor()
        let colors = [UIColor.blueColor(), UIColor.brownColor(), UIColor.greenColor()]
        for (index, component) in pageComponents.enumerate() {
            let componentView = component.view()
            print(component)
            componentView.translatesAutoresizingMaskIntoConstraints = false
            scrollViewContainerView.addSubview(componentView)
            
            component.updateHeightForComponentWithWidth(SCREENSIZE.size.width-20)
            componentView.backgroundColor = colors[index]
            
            let prefferedMargin = CGFloat(20.0) //component.prefferedMargin()/10 * SCREENSIZE.size.width
            if index == 0 {
                //scrollViewContainerView.addConstraint(NSLayoutConstraint(item: componentView, attribute: .Top, relatedBy: .Equal, toItem: scrollViewContainerView, attribute: .Top, multiplier: 1.0, constant: 0))
                scrollViewContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-12-[componentView]-12-|", options: .AlignAllBaseline, metrics: nil, views: ["componentView":componentView]))
            } else if let previousView = previousView {
                //scrollViewContainerView.addConstraint(NSLayoutConstraint(item: componentView, attribute: .Top, relatedBy: .Equal, toItem: previousView, attribute: .Bottom, multiplier: 1.0, constant: prefferedMargin))
                previousView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-12-[componentView]-12-|", options: .AlignAllBaseline, metrics: nil, views: ["componentView":componentView]))
            }
            
            scrollViewContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-12-[componentView]-12-|", options: .AlignAllBaseline, metrics: nil, views: ["componentView":componentView]))
            
            if index == pageComponents.count-1 {
                
                //scrollViewContainerView.addConstraint(NSLayoutConstraint(item: componentView, attribute: .Bottom, relatedBy: .Equal, toItem: scrollViewContainerView, attribute: .Bottom, multiplier: 1.0, constant: 0))
            }
            previousView = componentView
        }
        scrollViewContainerView.layoutIfNeeded()
        print(scrollViewContainerView.frame)*/
    }
    
    // MARK: - ContentPageComponentButtonDelegate
    
    func didTapUseContentButton(button: ContentPageComponentButton, ambassadorshipContentId: Int) {
        button.startLoading()
    
        ContentManager.sharedInstance.consumeAmbassadorshipContent(ambassadorshipContentId, completion: { (ambassadorshipContent, ambassadorshipContentConsumeData, error, message) in
            
            if let error = error {
                print("ambassadorshipContentConsumeData error: \( error.localizedDescription )")
            } else if let message = message {
                self.delegate?.showErrorMessage(message)
            } else {
                
                if let ambassadorshipContent = ambassadorshipContent {
                    if let ambassadorshipContentConsumeData = ambassadorshipContentConsumeData where ambassadorshipContentConsumeData.type == .Link {
                        if let consumeData = ambassadorshipContentConsumeData.consumeData {
                            var newUrl = "http://\(consumeData)"
                            if consumeData.rangeOfString("http") != nil {
                                newUrl = consumeData
                            }
                            self.delegate?.showLink(newUrl, ambassadorshipContent: ambassadorshipContent)
                        }
                    } else if let ambassadorshipContentConsumeData = ambassadorshipContentConsumeData where ambassadorshipContentConsumeData.type == .Code {
                        if let consumeData = ambassadorshipContentConsumeData.consumeData {
                            self.delegate?.showCode(consumeData, asQR: ambassadorshipContentConsumeData.showAsQr, ambassadorshipContent: ambassadorshipContent)
                        }
                    } else if ambassadorshipContent.content.consumeAction == ConsumeAction.OnlyConsumable {
                        self.delegate?.showContentConsumedWithAmbassadorshipContent(ambassadorshipContent)
                    }
                }
            }

            button.stopLoading()
        })
    }
    
    func didTapShareContentButton(button: ContentPageComponentButton, ambassadorshipContentId: Int) {
        button.startLoading()
        print("didTapShareContentButton: \(ambassadorshipContentId)")
        // TODO: Show user connections and call:
        // ContentManager.sharedInstance.shareAmbassadorshipContent(<#T##ambassadorshipContentId: Int##Int#>, targetUserId: <#T##Int#>, completion: <#T##AmbassadorshipContentResponseBlock##AmbassadorshipContentResponseBlock##(ambassadorshipContent: AmbassadorshipContent?, error: NSError?) -> ()#>)
    }

    // MARK: - Restore default state
    func resetToDefaultState() {
        for component in pageComponents {
            component.reset()
        }
    }
}
