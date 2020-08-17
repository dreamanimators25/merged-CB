//
//  UIView + Ext.swift
//  iList Ambassador
//
//  Created by IdeaSoft on 6/26/19.
//  Copyright © 2019 iList AB. All rights reserved.
//

import Foundation
import UIKit



extension UIView {
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var fullCornerRadiusEnabled: Bool {
        get {
            return layer.cornerRadius > 0
        }
        set {
            layer.cornerRadius = newValue ? frame.height / 2 : 0
        }
    }
    
    @IBInspectable var borderSizer: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    
    /// Returns the UIViewController object that manages the receiver.
    ///
    /// - Returns: UIViewController
    public func viewController() -> UIViewController? {
    
     var nextResponder: UIResponder? = self
        repeat {
            nextResponder = nextResponder?.next
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
        } while nextResponder != nil
     return nil
    }
}


extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}
