//
//  ContentButton.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-07-22.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class ContentButton: Button, ContentView {

    var touchUpInsideBlock: (()->Void)?
    var topMarginPercent: CGFloat = 0.0
    var horizontalMarginPercent: CGFloat = 12.0
    var bottomMarginPercent: CGFloat = 8.2
    var marginEdgePercentage: CGFloat = 0.0
    var view: UIView { return self }
    var height:CGFloat = 44.0
    var width: CGFloat = 0.0
    
    // MARK: - life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init(customTitle: String, touchUpInsideBlock: (()->Void)? = nil) {
        self.init(frame: CGRect.zero)
        self.touchUpInsideBlock = touchUpInsideBlock
        setTitle(customTitle, for: UIControl.State())
        setup()
    }
    
    func setup() {
        backgroundColor = Color.transparentBlueColor()
        titleColor = Color.whiteColor()
        titleLabel?.font = Font.titleFont(FontSize.ExtraLarge)
        addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
    }
    
    func prepareForReuse() {
        setTitle(nil, for: UIControl.State.normal)
    }
    
    // MARK: - Actions
    
    @objc func buttonPressed(_ sender: UIButton) {
        touchUpInsideBlock?()
    }
}
