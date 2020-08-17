//
//  ChangePasswordViewController.swift
//  iList Ambassador
//
//  Created by Dmitriy Zhyzhko on 05.03.2019.
//  Copyright © 2019 iList AB. All rights reserved.
//

import Foundation
import UIKit

final class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var oldPswTextField: UITextField!
    @IBOutlet weak var confNewPsfTextField: UITextField!
    @IBOutlet weak var newPswTextField: UITextField!
    
    @IBOutlet weak var newPswView: UIView!
    @IBOutlet weak var confirmNewPswView: UIView!
    @IBOutlet weak var oldPswView: UIView!
    
    @IBAction func onSavePressed(_ sender: Any) {
        if (newPswTextField.text?.isEmpty)! || (oldPswTextField.text?.isEmpty)! || (confNewPsfTextField.text?.isEmpty)! {
            self.showDialog("Fill in all the fields")
            return
        } else if confNewPsfTextField.text != newPswTextField.text {
            self.showDialog("Passwords don't match")
            return
        }
        
        UserManager.sharedInstance.changePsw(oldPswTextField.text!, newPswTextField.text!, onSuccess: {
            self.oldPswTextField.text = ""
            self.confNewPsfTextField.text = ""
            self.newPswTextField.text = ""
            self.showDialog("Password has been successfully changed")
        }, onError: {
            self.showDialog("Wrong old password")
        })
    }
    func makeBarButton()
    {
        self.makeNavigationBar()
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "left-arrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        let barButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.leftBarButtonItem = barButton
    }
    @objc func closeButtonTapped(_ sender: AnyObject?) {
        NotificationCenter.default.post(name: Notification.Name.init("showMenu"), object: nil, userInfo: ["data" : true])
        navigationController?.popViewController(animated: true)
        
    }
    @IBAction func onBackPressed(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.init("showMenu"), object: nil, userInfo: ["data" : true])
        navigationController?.popViewController(animated: true)
    }
    
    func showDialog(_ message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeBarButton()
        NotificationCenter.default.post(name: Notification.Name.init("showMenu"), object: nil, userInfo: ["data" : false])
        
//        newPswView.layer.cornerRadius = 23
//        newPswView.layer.borderWidth = 1
//        newPswView.layer.borderColor = UIColor.init(hexString: "4b23bd").cgColor
//        
//        confirmNewPswView.layer.cornerRadius = 23
//        confirmNewPswView.layer.borderWidth = 1
//        confirmNewPswView.layer.borderColor = UIColor.init(hexString: "4b23bd").cgColor
//        
//        oldPswView.layer.cornerRadius = 23
//        oldPswView.layer.borderWidth = 1
//        oldPswView.layer.borderColor = UIColor.init(hexString: "4b23bd").cgColor
        
        newPswTextField.attributedPlaceholder = NSAttributedString(string: "New password...",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: Color.newGray.withAlphaComponent(0.5)])
        
        confNewPsfTextField.attributedPlaceholder = NSAttributedString(string: "New password again...",
                                                                       attributes: [NSAttributedString.Key.foregroundColor: Color.newGray.withAlphaComponent(0.5)])
        
        oldPswTextField.attributedPlaceholder = NSAttributedString(string: "Old password...",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: Color.newGray.withAlphaComponent(0.5)])
    }
}
