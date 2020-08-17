//(
//  GradientView.swift
//  iList
//
//  Created by Pontus Andersson on 2014-09-29.
//  Copyright (c) 2014 iList. All rights reserved.
//

import UIKit


class GradientView: UIView {
    
    fileprivate var gradientLayer: CAGradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientLayer.frame = self.bounds
    }
    
    fileprivate func setup(){
        self.backgroundColor = UIColor.clear
        
//        let arrayWithColors: Array<AnyObject> = [ UIColor.clearColor().CGColor, ThemeHandler.sharedInstance.getTintColor().CGColor, ThemeHandler.sharedInstance.getTintColor().CGColor, UIColor.clearColor().CGColor]
//        let locations: Array<Float> = [0.0, 0.2, 0.8, 1.0]
//        self.setGradientColors(arrayWithColors, locations: locations)
    }
    
    func setDefaultGradientColors() {
//        let arrayWithColors: Array<AnyObject> = [ UIColor.clearColor().CGColor, ThemeHandler.sharedInstance.getTintColor().CGColor, ThemeHandler.sharedInstance.getTintColor().CGColor, UIColor.clearColor().CGColor]
//        let locations: Array<Float> = [0.0, 0.2, 0.8, 1.0]
//        self.setGradientColors(arrayWithColors, locations: locations)
    }

    func setAmbassadorListGradientColors() {
//        let arrayWithColors: Array<AnyObject> = [ ThemeHandler.sharedInstance.getTintColor().CGColor, UIColor.clearColor().CGColor ]
//        let locations: Array<Float> = [0.0, 0.9]
//        self.setGradientColors(arrayWithColors, locations: locations)
    }
    
    func setHorizontalGradientColors(_ arrayWithColors: Array<AnyObject>, locations: Array<Float>) {
        gradientLayer.frame = self.bounds
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5);
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5);
        
        gradientLayer.colors = arrayWithColors
        gradientLayer.locations = locations as [NSNumber]?
        
        self.layer.addSublayer(gradientLayer) //insertSublayer(gradientLayer, atIndex: 0)
    }
    
    func setVerticalGradientColors(_ arrayWithColors: Array<AnyObject>, locations: Array<Float>) {
        gradientLayer.frame = self.bounds
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0);
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0);
        
        gradientLayer.colors = arrayWithColors
        gradientLayer.locations = locations as [NSNumber]?
        
        self.layer.addSublayer(gradientLayer) //insertSublayer(gradientLayer, atIndex: 0)
    }
}
