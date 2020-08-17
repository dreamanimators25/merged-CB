//
//  CreateAccountFinishViewController.swift
//  iList Ambassador
//
//  Created by Dmitriy Zhyzhko on 12.09.2018.
//  Copyright © 2018 iList AB. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountFinishViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var checkbox: Checkbox!
    
    @IBOutlet weak var policyLabel: UILabel!
    @IBOutlet weak var agreementLabel: UILabel!
    @IBOutlet weak var gdprLabbel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordAgainTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var lan = "sv"
    
    var firstName = ""
    var lastName = ""
    var countryCode = ""
    var birthday = ""
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
self.makeBarButton()
        self.makeTxtFldRound()
        checkbox.checkmarkColor = UIColor.black
        checkbox.checkedBorderColor = UIColor.black
        checkbox.uncheckedBorderColor = UIColor.black
        checkbox.checkmarkStyle = .tick
        
        emailTextField.delegate = self
        passwordAgainTextField.delegate = self
        passwordTextField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(firstLink))
        agreementLabel.isUserInteractionEnabled = true
        agreementLabel.addGestureRecognizer(tap)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(secondLink))
        policyLabel.isUserInteractionEnabled = true
        policyLabel.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(thirdLink))
        gdprLabbel.isUserInteractionEnabled = true
        gdprLabbel.addGestureRecognizer(tap2)
        
        if Locale.current.languageCode == "en" {
            lan = "en"
        }
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
    
    func makeTxtFldRound()
    {
        self.emailTextField.layer.cornerRadius = 7.0
        self.emailTextField.clipsToBounds = true
        
        self.passwordTextField.layer.cornerRadius = 7.0
        self.passwordTextField.clipsToBounds = true
        
        self.passwordAgainTextField.layer.cornerRadius = 7.0
        self.passwordAgainTextField.clipsToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.screenType == UIDevice.ScreenType.iPhones_5_5s_5c_SE {
            topConstraint.constant = 35
            bottomConstraint.constant = 24
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.emailTextField) {
            self.passwordTextField.becomeFirstResponder()
        } else if (textField == self.passwordTextField) {
            self.passwordAgainTextField.becomeFirstResponder()
        } else if (textField == self.passwordAgainTextField) {
            self.view.endEditing(true)
        }
        return false
    }
    
    @objc func firstLink() {
        guard let url = URL(string: "http://www.jokk.app/agreementsv") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func secondLink() {
        guard let url = URL(string: "http://www.jokk.app/privacysv") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func thirdLink() {
        guard let url = URL(string: "http://www.jokk.app/gdprsv") else { return }
        UIApplication.shared.open(url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        if !isValidEmail(testStr: emailTextField.text!) {
            showErr(str: "E-mail is invalid")
        } else if passwordTextField.text!.count < 6 {
            showErr(str: "Password is too short")
        } else if passwordTextField.text != passwordAgainTextField.text  {
            showErr(str: "Passwords do not match")
        } else if !checkbox.isChecked {
            showErr(str: "You need to agree with the license to continue")
        } else {
            var params = [String : String]()
            params["first_name"] = firstName
            params["last_name"] = lastName
            params["email"] = emailTextField.text!
            params["password"] = passwordTextField.text!
            params["country"] = countryCode
//            params["birth_date"] = birthday
            params["gender"] = "unspecified"
            
            print("parass = \(params)")
            
            UserManager.sharedInstance.registerWithUsername(params) { [weak self]
               (user, error, exist) in
                
                guard let self = self else { return }
                
                if error != nil {
                    self.showErr(str: "Server error")
                } else if exist {
                    self.showErr(str: "Email address already in use")
                } else {
                    if user == nil {
                         self.showErr(str: "Server error")
                    } else {
                        AppDelegate.userId = user?.id
                        
//                        let vc = TutorialViewController.init()
//                        self.present(vc, animated: true, completion: nil)
                        self.updatePushToken()
                        DispatchQueue.main.async(execute: {
                            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                appDelegate.navigateToApplication()
                            }
                        })
                    }
                }
            };
        }
    }

    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

}


extension CreateAccountFinishViewController {
    
    //MARK: - Updating Push Notification Token -
    
    fileprivate func updatePushToken() {
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            
            AppDelegate.token = result?.token
            
            if let id = UserManager.sharedInstance.user?.id, let token = AppDelegate.token {
                let router = UserRouter(endpoint: .updatePushToken(token: token, userId: "\(id)"))
                UserManager.sharedInstance.performRequest(withRouter: router) { (data) in
                    print("👍", String(describing: type(of: self)),":", #function, " ", data)
                }
            }
        })
    }
}
