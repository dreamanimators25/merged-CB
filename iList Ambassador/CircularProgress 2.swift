//
//  ViewController.swift
//  Filterlapse
//
//  Created by Mathias on 2014-09-12.
//  Copyright (c) 2014 Mathias Palm. All rights reserved.
//

import Foundation
import UIKit


// MARK: - CircularProgress
class CircularProgress: UIView {

    var backgroundLayer: CAShapeLayer!
    var strokeLayer: CAShapeLayer!
    
    var lineWidth:CGFloat = 10.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        let circleCenter = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        let start = CGFloat(-Double.pi / 2)
        let end = CGFloat(Double.pi) * 2.0
        let circlePath = UIBezierPath(arcCenter: circleCenter, radius: frame.size.width/2, startAngle: start, endAngle: end, clockwise: true)
        backgroundLayer = CAShapeLayer()
        backgroundLayer.rasterizationScale = 4 * UIScreen.main.scale
        backgroundLayer.shouldRasterize = true
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7).cgColor
        backgroundLayer.lineWidth = lineWidth
        
        backgroundLayer.strokeEnd = 1.0
        
        strokeLayer = CAShapeLayer()
        strokeLayer.rasterizationScale = 2 * UIScreen.main.scale
        strokeLayer.shouldRasterize = true
        strokeLayer.path = circlePath.cgPath
        strokeLayer.fillColor = UIColor.clear.cgColor
        strokeLayer.strokeColor = Color.blueColor().cgColor
        strokeLayer.lineWidth = lineWidth
        
        strokeLayer.strokeEnd = 0.0
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(strokeLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var progress: Double = 0.0 {
        didSet(newValue) {
            let clipProgress = max( min(newValue, 1.0), 0.0)
            self.updateProgress(clipProgress)

        }
    }
    func updateProgress(_ progress: Double) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.strokeLayer.strokeEnd = CGFloat(progress)
        CATransaction.commit()
    }
}
