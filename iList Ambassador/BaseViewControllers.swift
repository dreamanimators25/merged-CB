//
//  BaseViewController.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 18/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    // Sameer 18/4/2020
    /*
     
    // MARK: - Alerts
    
    @objc func showAlertWithTitle(_ title: String, message: String?, dismissTitle: String? = nil, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var dismissActionTitle = NSLocalizedString("OK", comment: "")
        if let dismissTitle = dismissTitle {
            dismissActionTitle = dismissTitle
        }
        alertController.addAction(UIAlertAction(title: dismissActionTitle, style: .cancel, handler: { (alertAction: UIAlertAction) in
            alertController.dismiss(animated: true, completion: completion)
        }))
        present(alertController, animated: true, completion: nil)
    }*/
    
}

class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.backgroundColorWhite()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Show/Hide Navigation Bar
    
    func setTranparentNavigationBar(_ transparent: Bool) {
        if transparent {
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
            navigationBar.isTranslucent = true
            navigationBar.backgroundColor = UIColor.clear
            
        } else {
            navigationBar.setBackgroundImage(nil, for: .default)
        }
    }
    
}
