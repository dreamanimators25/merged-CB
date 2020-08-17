//
//  NavigationBar.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 09/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import FontAwesomeKit

let navigationBarIconSize = CGFloat(22.0)

class NavigationBar: UINavigationBar {
    
    // Views
    lazy var navigationBarSeparator: UIImageView? = {
        for view in self.subviews {
            for view2 in view.subviews {
                if let view2 = view2 as? UIImageView {
                    return view2
                }
            }
        }
        return nil
    }()
    
    // Properties
    static let titleAttributes = [
        NSAttributedString.Key.foregroundColor: Color.whiteColor(),
        NSAttributedString.Key.font: Font.titleFont(FontSize.ExtraLarge)
    ]
    
    static let subtitleAttributes = [
        NSAttributedString.Key.foregroundColor: Color.blackColor(),
        NSAttributedString.Key.font: Font.normalFont(FontSize.Normal)
    ]
    
    static let barButtonAttributes = [
        NSAttributedString.Key.foregroundColor : Color.blueColor(),
        NSAttributedString.Key.font : Font.normalFont(FontSize.Normal)
    ]
    
    // MARK: - View life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        //NavigationBar.styleNavigationBar(self)
    }
    
    class func styleNavigationBar(_ navigationBar: UINavigationBar) {
        navigationBar.isTranslucent = false
        
        navigationBar.barTintColor = .white
        navigationBar.tintColor = Color.blueColor()
        
        navigationBar.titleTextAttributes = titleAttributes
        
        UIBarButtonItem.appearance().setTitleTextAttributes(barButtonAttributes, for: UIControl.State())
        
        // Custom back button
        var backButtonImage = UIImage(named: "backarrow")
        backButtonImage = backButtonImage?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        navigationBar.backIndicatorImage = backButtonImage
        navigationBar.backIndicatorTransitionMaskImage = backButtonImage
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        
        // Bottom separator color
        //        navigationBarSeparator?.backgroundColor = Color.veryLightGrayColor()
        
        
        // Remove back button title
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: -60), for: UIBarMetrics.default)

    }
    
    func labelForTitle(_ title: String, subtitle: String) -> UILabel {
        let subviewFrame = self.bounds.insetBy(dx: 8, dy: 0)
        
        let titleLabel = UILabel(frame: subviewFrame)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: title, attributes: NavigationBar.titleAttributes))
        attributedString.append(NSAttributedString(string: "\n", attributes: NavigationBar.subtitleAttributes))
        attributedString.append(NSAttributedString(string: subtitle, attributes: NavigationBar.subtitleAttributes))
        
        
        
        let style = NSMutableParagraphStyle()
        //        style.lineSpacing = 24
        style.lineHeightMultiple = 0.8
        style.alignment = .center
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSMakeRange(title.count+1, subtitle.count))
        
        titleLabel.attributedText = attributedString
        titleLabel.sizeToFit()
        
        return titleLabel
    }
    
    // MARK: - Help functions
    
    class func closeButtonWithTarget(_ target: AnyObject?, action: Selector) -> UIBarButtonItem {
//        let closeIcon = FAKFontAwesome.closeIconWithSize(navigationBarIconSize)
//        let closeImage = closeIcon.imageWithSize(CGSizeMake(closeIcon.iconFontSize, closeIcon.iconFontSize))
        
        let closeImage = UIImage(named: "close")?.withRenderingMode(.alwaysOriginal)
        
        return UIBarButtonItem(image: closeImage, style: .plain, target: target, action: action)
    }
}

extension UIImage {
    
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(self.cgImage!, in: newRect)
            let newImage = UIImage(cgImage: context.makeImage()!)
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
}
