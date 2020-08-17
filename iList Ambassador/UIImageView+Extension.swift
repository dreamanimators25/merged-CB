//
//  UIImageView+Extension.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-07-21.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

extension UIImageView {
    func makeBlurImage() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibracneView = UIVisualEffectView(effect: vibrancyEffect)
        vibracneView.frame = bounds
        vibracneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(vibracneView)
    }
}
