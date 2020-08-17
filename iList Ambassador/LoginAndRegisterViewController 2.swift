//
//  LoginAndRegisterViewController.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-05-14.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SafariServices
import Crashlytics
import FirebaseCore
import FirebaseInstanceID


// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

extension UIDevice {
    
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    public enum ScreenType: String {
        case iPhone4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown
    }
    
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX
        default:
            return .unknown
        }
    }
}


class LoginAndRegisterViewController: BaseViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundImageLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var customFBButton: UIButton!
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var facebookButtonPlaceholderLogin: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    lazy var facebookLoginButtonLogin: FBSDKLoginButton = {
        
        let button = FBSDKLoginButton(type: UIButtonType.custom)
        button.loginBehavior = FBSDKLoginBehavior.native
        button.delegate = self
        button.readPermissions = ["public_profile", "email"]
       // self.customFBButton.addSubview(button)
        return button
    }()
    
    private let fbLoginManager = FBSDKLoginManager()

    
    enum LoginViewStyle {
        case login
        case register
    }
    enum RegisterView {
        case emailAndPassword
        case birthYear
    }
    
    @IBAction func lostPassPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LostPasswordViewController")
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)    }
    
    @IBAction func createAccPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController")

        let nav = UINavigationController(rootViewController: vc)
        
        self.present(nav, animated: true, completion: nil)
    }
    
    
    @IBAction func agreeAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myModalViewController = storyboard.instantiateViewController(withIdentifier: "agreeID") as! AgreementViewController
        myModalViewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        myModalViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        myModalViewController.view.backgroundColor = UIColor.init(red: 084.0/255.0, green: 084.0/255.0, blue: 084.0/255.0, alpha: 0.7)
        self.present(myModalViewController, animated: true, completion: nil)

        myModalViewController.closure = {

            self.fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: { (result, errrror) in
            })
        }
    }
    var activeTextField = 0
    var loginViewStyle: LoginViewStyle = .login
    var currentRegisterView: RegisterView = .emailAndPassword
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        
        self.versionLbl.text = "V \(appVersion ?? "")"

        
//        if let image = backgroundImageView.image {
//            let i = resizeImage(image)
//            backgroundImageView.image = i
//            backgroundImageWidthConstraint.constant = i.size.width
//            view.layoutIfNeeded()
//        }
    }

    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if FBSDKAccessToken.current() != nil {
            UserManager.sharedInstance.fetchFacebookUserInfo({ [weak self] (user, error) in
                if let user = user, user.id != 0 {
                    AppDelegate.userId = user.id
                    
//                    let vc = TutorialViewController.init()
//                    self?.present(vc, animated: true, completion: nil)
//
                    self?.handleSuccessfullyAuthenticatedWithUser()
                }else if let error = error {
                    debugPrint("FB Login: fetchFacebookUserInfo error: \( error.localizedDescription )")
                        // Logout if not successfully logged in
                    self?.fbLoginManager.logOut()
                }
            })
        }
        
        print("gg = \(InstanceID.instanceID().token())")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        facebookLoginButtonLogin.frame = facebookButtonPlaceholderLogin.bounds
    }
    
    func resizeImage(_ image:UIImage) -> UIImage {
        let screenHeight = SCREENSIZE.height
        let screenWidth = SCREENSIZE.width
        let ratio = screenWidth / screenHeight
        
        let newWidth = ratio * image.size.width
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: screenHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: screenHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillHide)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillShow)
    }

    @IBAction func loginPressed(_ sender: Any) {
        if !isValidEmail(testStr: emailTextField.text!) {
            showErr(str: "E-mail is invalid")
        } else if passwordTextField.text!.isEmpty {
            showErr(str: "You need to enter a password")
        } else {
            UserManager.sharedInstance.authenticateWithUsername(emailTextField.text!, password: passwordTextField.text!) { (user, error, text) in
            
                if text != nil {
                    self.showErr(str: text!)
                } else if error != nil {
                    self.showErr(str: "Server error")
                } else {
                    AppDelegate.userId = user?.id
//                    let vc = TutorialViewController.init()
//                    self.present(vc, animated: true, completion: nil)
                    
                    CustomUserDefault.saveUserData(modal: user ?? User())
//
                    self.handleSuccessfullyAuthenticatedWithUser()
                }
            }
        }
    }
    
    // MARK: - Login

    
}

extension UIViewController {
    func handleSuccessfullyAuthenticatedWithUser() {
        print("The login was successful, so navigating to the applocation.")
        updatePushToken()
        DispatchQueue.main.async(execute: {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.navigateToApplication()
            }
        })
    }
}

extension LoginAndRegisterViewController: FBSDKLoginButtonDelegate {

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // Do nothing
        print("loginButtonDidLogOut")
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        
        return true
    }
    // ÄNDRAD FACEBOOK
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("didCompleteWithResult")
        if error != nil {
            debugPrint("FB Login Error: \( error.localizedDescription )")
        } else if result.isCancelled {
            debugPrint("FB Login Error: Login was cancelled")
        } else {
            UserManager.sharedInstance.fetchFacebookUserInfo({ (user, error) in
                if let user = user {
//                    let vc = TutorialViewController.init()
//                    self.present(vc, animated: true, completion: nil)
                    self.handleSuccessfullyAuthenticatedWithUser()
                } else if let error = error {
                    debugPrint("FB Login Error: fetchFacebookUserInfo: \(error.localizedDescription)")
                }
            })
        }
    }
    
}


extension UIViewController {
    
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
