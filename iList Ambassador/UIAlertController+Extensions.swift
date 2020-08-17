//
//  UIAlertController+Extensions.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 18/06/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

public extension UIAlertController {
    
    public class func dismissableAlertController(_ title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert, completion: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: { (alertAction: UIAlertAction) in
            alertController.dismiss(animated: true, completion: completion)
        }))
        
        return alertController
    }
    
}
