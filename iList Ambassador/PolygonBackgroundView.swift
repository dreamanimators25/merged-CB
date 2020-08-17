//
//  PolygonBackgroundView.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-05-14.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class PolygonBackgroundView: UIView {

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        UIColor.white.setFill()
        UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 0.3).setStroke()
        path.lineWidth = 4.0
        
        let verticalOffset = rect.maxY / 4
        let horizontalOffset = rect.maxX / 4
        
        path.move(to: CGPoint(x: rect.minX - path.lineWidth, y: rect.maxY - verticalOffset))
        
        path.addLine(to: CGPoint(x: horizontalOffset, y: rect.maxY-path.lineWidth))
        path.addLine(to: CGPoint(x: rect.maxX - horizontalOffset, y: rect.maxY-path.lineWidth))
        path.addLine(to: CGPoint(x: rect.maxX + path.lineWidth, y: rect.maxY - verticalOffset))
        
        path.stroke()
        path.fill()
    }

}
