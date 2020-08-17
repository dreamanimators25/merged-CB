//
//  TextField.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 16/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class TextField: UITextField {
    
    fileprivate let horizontalPadding: CGFloat = 8.0
    fileprivate let verticalPadding: CGFloat = 0.0
    
    fileprivate let defaultFont = Font.normalFont(FontSize.ExtraLarge)
    
    var placeholderColor: UIColor = Color.blackColor().withAlphaComponent(0.5)
    
    override var placeholder: String? {
        didSet {
            if let placeholder = placeholder {
                let attributes = [
                    NSAttributedString.Key.foregroundColor.rawValue : placeholderColor,
                    NSAttributedString.Key.font : defaultFont
                    ] as! [NSAttributedString.Key : Any]
                
                self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
            }
        }
    }
    
    var editingDidChangeBlock: ((TextField)->())?

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
        backgroundColor = Color.lightGrayColor()
        layer.cornerRadius = CornerRadius.Default
        
        borderStyle = .none
        clearButtonMode = .whileEditing
        
        font = defaultFont
        textColor = Color.textColorDark()
        
        addTarget(self, action: #selector(editingDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - Actions
    
    @objc func editingDidChange(_ textField: TextField) {
        if let editingDidChangeBlock = editingDidChangeBlock {
            editingDidChangeBlock(textField)
        }
    }

    // MARK: - Layout
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.insetBy(dx: horizontalPadding, dy: verticalPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
}
