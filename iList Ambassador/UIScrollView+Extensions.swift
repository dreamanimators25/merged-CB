//
//  UIScrollView+Extensions.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 10/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func scrollHorizontal(_ content: Int, animated: Bool) {
        var frame: CGRect = self.frame
        frame.origin.x = frame.size.width * CGFloat(content)
        frame.origin.y = 0
        self.scrollRectToVisible(frame, animated: animated)
    }
    
    func scrollVertical(_ page: Int, animated: Bool) {
        var frame: CGRect = self.frame
        frame.origin.y = frame.size.height * CGFloat(page)
        frame.origin.x = 0
        self.scrollRectToVisible(frame, animated: animated)
    }
    
    func numberOfHorizontalPages() -> Int {
        return Int(self.contentSize.width/self.frame.width)
    }
    
    func numberOfVerticalPages() -> Int {
        return Int(self.contentSize.height/self.frame.height)
    }
    
    func currentHorizontalPage() -> Int {
        let width = self.frame.width
        return Int((self.contentOffset.x + (0.5 * width))/width)
    }
    
    func currentVerticalPage() -> Int {
        let height = self.frame.height
        return Int((self.contentOffset.y + (0.5 * height))/height)
    }
}
