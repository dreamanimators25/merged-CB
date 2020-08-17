//
//  LostPasswordViewController.swift
//  iList Ambassador
//
//  Created by Dmitriy Zhyzhko on 12.09.2018.
//  Copyright © 2018 iList AB. All rights reserved.
//

import UIKit

class LostPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.layer.cornerRadius = 7.0
        self.emailTextField.clipsToBounds = true
        self.makeBarButton()

        // Do any additional setup after loading the view.
    }

    func makeBarButton()
    {
        self.makeNavigationBar()
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "logo_small")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        let barButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.rightBarButtonItem = barButton
    }
    @objc func closeButtonTapped(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        guard let text = emailTextField.text else { return }
        if text.isEmpty || !isValidEmail(testStr: text) {
            let alertController = UIAlertController(title: nil, message: "E-mail is invalid", preferredStyle: UIAlertController.Style.alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        UserManager.sharedInstance.restorePasswordWithEmail(text) { (res, error, info) in
            if error != nil {
                self.showErr(str: "Server error")
            } else if let info = info {
                self.showErr(str: info)
            } else {
                self.showErr(str: "An email has been sent")
                self.emailTextField.text = ""
            }
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
      self.dismiss(animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
