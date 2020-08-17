//
//  UIViewController+Extensions.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 2017-01-05.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    func showErrorAlert(withMessage message: String) {
        let alertController = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: message, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: { (action: UIAlertAction) in
            alertController.dismiss(animated: true)
        }))
        present(alertController, animated: true)
    }
    
    func showErr(str: String) {
        let alertController = UIAlertController(title: nil, message: str, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWithTitle(_ title: String, message: String?, dismissTitle: String? = nil, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var dismissActionTitle = NSLocalizedString("OK", comment: "")
        if let dismissTitle = dismissTitle {
            dismissActionTitle = dismissTitle
        }
        alertController.addAction(UIAlertAction(title: dismissActionTitle, style: .cancel, handler: { (alertAction: UIAlertAction) in
            alertController.dismiss(animated: true, completion: completion)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    
    
}
