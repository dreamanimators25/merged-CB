//
//  ContentText.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-07-21.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class ContentText: UITextView, ContentView {
    
    var topMarginPercent: CGFloat = 0.0
    var horizontalMarginPercent: CGFloat = 0.0
    var bottomMarginPercent: CGFloat = 0.0
    var marginEdgePercentage: CGFloat = 0.0
    var view: UIView { return self }
    var height:CGFloat = 0.0
    var width: CGFloat = 0.0
    var backColor : UIColor = UIColor.clear
    
    var color: UIColor = UIColor.white
    var cent: CGPoint!
    var alpa : CGFloat!
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init(meta: Meta, bottomMarginPercent: CGFloat, horizontalMarginPercent: CGFloat, CNTR : CGPoint = CGPoint(x: 0,y: 0)) {
        
        self.init(frame: CGRect.zero, textContainer: nil)
        self.horizontalMarginPercent = horizontalMarginPercent
        self.bottomMarginPercent = bottomMarginPercent
        
        self.text = meta.text
        self.font = meta.font
        self.color = meta.color
        self.textAlignment = meta.textAlignment
        self.alpa = meta.background_opacity
                
        
        //self.goThereBtn.backgroundColor = self.goThereBtn.backgroundColor?.withAlphaComponent(opacty)
        
        //print("Meta Text is :- \(meta.text)")
        //print("backGround Box is :- \(meta.background_box)")
        //print(meta.bgColor)
        //print(meta.size)
        
        //cent = CNTR
        //self.bottomMarginPercent = 100.0
        //self.backColor = meta.bgColor
        
        //*
        if meta.background_box == "false" {
            
            //self.backColor = UIColor.clear
            //cent = CNTR
            //self.bottomMarginPercent = bottomMarginPercent
            
            if self.text == "" {
                self.backColor = UIColor.clear
                
                print("Meta Text is :- \(meta.text)")
            }else {
                print("Meta Text is :- \(meta.text)")
                
                //self.bottomMarginPercent = 45
            }
            
        }else if meta.background_box == "true" {
            
            if self.text.count < 20 {
                if self.text == "" {
                    self.backColor = UIColor.clear
                    
                    print("Meta Text is :- \(meta.text)")
                }else {
                    //cent = CNTR
                    //self.bottomMarginPercent = bottomMarginPercent

                    //self.bottomMarginPercent = 45
                    print("Meta Text is :- \(meta.text)")
                    
                    self.backColor = meta.bgColor
                    
                }
                
            }else {
                if self.text == "" {
                    self.backColor = UIColor.clear
                    
                    print("Meta Text is :- \(meta.text)")
                }else {
                    cent = CNTR
                    ///////////////////////////////////////////////////////
//                    switch UIScreen.main.nativeBounds.height {
//                    //case 960:
//                        //return .iPhone4
//                    case 1136:
//                        self.bottomMarginPercent = 50.0
//                        //return .iPhone5
//                    case 1334:
//                        self.bottomMarginPercent = 60.0
//                        //return .iPhone6
//                    case 2208, 1920:
//                        self.bottomMarginPercent = 80.0
//                        //return .iPhone6Plus
//                    case 2436:
//                        self.bottomMarginPercent = 90.0
//                        //return .iPhoneX
//                    default:
//                        self.bottomMarginPercent = 90.0
//                        //return .Unknown
//                    }
                    ///////////////////////////////////////////////////////
                    //self.bottomMarginPercent = 80.0
                    //self.bottomMarginPercent = 45.0
                    
                    
                    print("Meta Text is :- \(meta.text)")
                    //self.bottomMarginPercent = bottomMarginPercent + 20
                    self.backColor = meta.bgColor
                                        
                }
            }
            
            
            /*
            if self.text == "" {
                self.backColor = UIColor.clear
            }else {
                //cent = CNTR
                self.bottomMarginPercent = 80.0
                
                self.backColor = meta.bgColor
            }*/
            
        }else {
            if self.text == "" {
                self.backColor = UIColor.clear
                
                
                print("Meta Text is :- \(meta.text)")
            }else {
                self.backColor = meta.bgColor
                
                //self.bottomMarginPercent = 45
                self.bottomMarginPercent = bottomMarginPercent + 10
                print("Meta Text is :- \(meta.text)")
                
            }
        }//*/
        
        setup()
                        
    }

    fileprivate func setup() {
        textColor = self.color
        tintColor = Color.blueColor()
        self.textContainerInset = UIEdgeInsets.zero

        self.isScrollEnabled = false
        self.delegate = self
        self.isEditable = false
        self.isSelectable = true
        self.dataDetectorTypes = .link
        self.linkTextAttributes = [NSAttributedString.Key.foregroundColor : Color.lightBlueColor()] as [NSAttributedString.Key : Any]
        self.backgroundColor = self.backColor
        
        if self.alpa != nil && self.alpa != 0.0 {
            self.backgroundColor = self.backColor.withAlphaComponent(self.alpa)
        }

        self.layer.cornerRadius = 10.0 // Sameer 24/4/2020
                
        let screenWidht = SCREENSIZE.width - 20
        let width = screenWidht-((self.horizontalMarginPercent/100 * 2) * screenWidht)
        
        if let font = self.font {
            if let height = self.text?.heightWithConstrainedWidth(width, font: font) {
                self.height = height
                print("height of text is: \(height)")
            }
            self.width = width
        }
    }
    
    func prepareForReuse() {
        self.text = nil
    }

    override var canBecomeFirstResponder : Bool {
        return false
    }
    
}

extension ContentText: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
}
