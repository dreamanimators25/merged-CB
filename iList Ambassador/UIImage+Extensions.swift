//
//  UIImage+Extensions.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-05-17.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resizeImage(_ newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    class func qrImageForCode(_ code: String, size: CGFloat) -> UIImage? {
        let stringData: Data = code.data(using: String.Encoding.utf8, allowLossyConversion: true)!
        if let qrFilter = CIFilter(name: "CIQRCodeGenerator") {
            qrFilter.setValue(stringData, forKey: "inputMessage")
            qrFilter.setValue("H", forKey: "inputCorrectionLevel")
            
            if let theImage = qrFilter.outputImage{
                let scaleX = size/theImage.extent.size.width
                let scaleY = size/theImage.extent.size.height
                let transformedImage = theImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
                let qrImage = UIImage(ciImage: transformedImage)
                return qrImage
            }
        }
        return nil
    }
    
}
