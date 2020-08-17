//
//  OvalBackgroundView.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 06/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class OvalBackgroundView: UIView {

    lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 0.0
        shapeLayer.fillColor = UIColor.white.cgColor
        return shapeLayer
    }()
    
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
        backgroundColor = UIColor.clear
        
        shapeLayer.path = createPath().cgPath
        layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.shapeLayer.path = createPath().cgPath;
    }
    
    // MARK: - Path
    
    fileprivate func createPath() -> UIBezierPath {
        let path = UIBezierPath()
        
        let horizontalControlPointOffset = CGFloat(40.0)
        let verticalControlPointOffset = CGFloat(40.0)
        
        path.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.maxY - 16))
        
        path.addCurve(to: CGPoint(x: self.bounds.midX, y: self.bounds.minY), controlPoint1: CGPoint(x: self.bounds.minX + horizontalControlPointOffset, y: self.bounds.maxY - verticalControlPointOffset), controlPoint2: CGPoint(x: self.bounds.midX - horizontalControlPointOffset, y: self.bounds.minY))
        
        path.addCurve(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY - 16), controlPoint1: CGPoint(x: self.bounds.midX + horizontalControlPointOffset, y: self.bounds.minY), controlPoint2: CGPoint(x: self.bounds.maxX - horizontalControlPointOffset, y: self.bounds.maxY - verticalControlPointOffset))
        
        path.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY))
        path.addLine(to: CGPoint(x: self.bounds.minX, y: self.bounds.maxY))
        path.addLine(to: CGPoint(x: self.bounds.minX, y: self.bounds.minY))
        
        path.close()
        
        return path
    }

}
