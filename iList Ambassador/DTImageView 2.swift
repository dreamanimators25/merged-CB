//
//  DTImageView.swift
//  Joy
//
//  Created by Dmitriy Yurchenko on 2/14/19.
//

import UIKit

@IBDesignable class DTImageView: UIImageView {
    
    //MARK: - Public properties -
    
    @IBInspectable var imageColor: UIColor = .white{
        didSet {
            image = image?.imageWithColor(color1: imageColor)
        }
    }
    
    //MARK: - Lifecycle -
    
    override open var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize.zero)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let image = image else { return CGSize.zero}
        let multiplier = image.size.height / image.size.width
        return CGSize(width: frame.width, height: frame.width * multiplier)
    }
}
