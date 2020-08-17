//
//  SettingsTableViewController.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-08-20.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI
import FBSDKCoreKit
import FBSDKShareKit
import FacebookShare


class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    var isMenu = false
    
    @IBAction func x(_ sender: AnyObject?) {
        if let navController = self.navigationController {
            if (isMenu) {
                let transition = CATransition()
                transition.duration = 0.4
                transition.type = CATransitionType.push
                transition.subtype = CATransitionSubtype.fromRight
                transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.popViewController(animated: true)
            } else {
                navController.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
        //dismiss(animated: true, completion: nil)
    }
   
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeBarButton()
        tableView.separatorStyle = .none
//        tableView.backgroundColor = .white
//       // tableView.contentInset = UIEdgeInsetsMake(-18, 0, 0, 0)
        self.tableView.estimatedRowHeight = 200;
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundView = UIImageView(image: UIImage(named: "white_bg"))
        print(user?.searchable! ?? "Could not print searchable")
        
//        let button = UIButton.init(type: .system)
//        button.setTitle(NSLocalizedString("LOGOUT", comment: ""), for: .normal)
//        button.sizeToFit()
//        button.titleLabel?.font = UIFont(name: "MyriadPro-Bold", size: 20)
//        button.setTitleColor(UIColor.init(hexString: "bd236f"), for: .normal)
//        button.addTarget(self, action: #selector(logoutPressed(_:)), for: .touchDown)
//        self.view.addSubview(button)
//
//        //set constrains
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.leftAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.leftAnchor, constant: 45).isActive = true
//        button.bottomAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
    }
    
    func makeBarButton()
    {
        self.makeNavigationBar()
        self.navigationItem.hidesBackButton = true
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "logo_small")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        let barButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.rightBarButtonItem = barButton
    }
    @objc func closeButtonTapped(_ sender: AnyObject?) {
       // self.navigationController?.popViewController(animated: true)
        self.x(sender)
    }
    
    
    @IBAction func logoutPressed(_ button: UIButton) {
        logoutUser()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "editProfileSegue" {
//            let destination = segue.destination as! EditProfileViewController
//            destination.user = user
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 1 {
//
//            switch indexPath.row {
//            case 0:
//                let activityVC = UIActivityViewController(activityItems: [NSLocalizedString("ILIST_SHARE_LINK", comment: "")], applicationActivities: nil)
//                activityVC.popoverPresentationController?.sourceView = self.view
//                activityVC.excludedActivityTypes = [
//                    UIActivityType.airDrop, UIActivityType.mail,
//                    UIActivityType.openInIBooks, UIActivityType.postToFacebook, UIActivityType.postToFlickr,
//                    UIActivityType.postToTencentWeibo, UIActivityType.postToTwitter, UIActivityType.postToVimeo,
//                    UIActivityType.postToWeibo, UIActivityType.print, UIActivityType.saveToCameraRoll
//                ]
//                self.present(activityVC, animated: true, completion: nil)
//
//            case 1:
//                performSegue(withIdentifier: "editProfileSegue", sender: self)
//
//            case 2:
//                //Edit password segue
//                break
//            case 3:
//                showPrivacy()
//            case 4:
//                showUserAgreements()
//            case 5:
//                showGDPR()
//            case 6:
//                promptOptOutUser()
//            case 7:
//                promptLogoutUser()
//            default:
//                break
//            }
//
//        }
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            
            switch indexPath.row {
//            case 0:
//                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
//                vc.user = UserManager.sharedInstance.user
//                navigationController?.pushViewController(vc, animated: true)
                
            case 0:
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditMyProfileViewController") as! EditMyProfileViewController
                vc.user = UserManager.sharedInstance.user
                navigationController?.pushViewController(vc, animated: true)
           
//            case 2:
//                //performSegue(withIdentifier: "editProfileSegue", sender: self)
//                //Inbox
//                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentInboxViewController") as! ContentInboxViewController
//                vc.user = UserManager.sharedInstance.user
//                navigationController?.pushViewController(vc, animated: true)
//                break
            case 1:
                //connections
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewConnectionsViewController") as! NewConnectionsViewController
                navigationController?.pushViewController(vc, animated: true)
                break
            case 2:
                //password
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
                navigationController?.pushViewController(vc, animated: true)
                break
            case 3:
                showUserAgreements()
            case 5:
                showGDPR()
            case 4:
                showPrivacy()
                
//            case 6:
//                let activityVC = UIActivityViewController(activityItems: ["Hi, I have just started using a really cool app named appin. Try it out!"], applicationActivities: nil)
//                activityVC.popoverPresentationController?.sourceView = self.view
//                activityVC.excludedActivityTypes = [
//                    UIActivityType.airDrop, UIActivityType.mail,
//                    UIActivityType.openInIBooks, UIActivityType.postToFacebook, UIActivityType.postToFlickr,
//                    UIActivityType.postToTencentWeibo, UIActivityType.postToTwitter, UIActivityType.postToVimeo,
//                    UIActivityType.postToWeibo, UIActivityType.print, UIActivityType.saveToCameraRoll
//                ]
//                self.present(activityVC, animated: true, completion: nil)
                
            case 6:
                promptOptOutUser()
                
            case 7:
                logoutUser()
                
            default:
                break
            }
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        switch section {
        case 0:
            return 1
        case 1:
            return 8
        default:
            return 0
        }
    }
    
    // TODO: Privacy policy?
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Settings", for: indexPath) as! SettingsCell
       // cell.backgroundColor = .white
        
        if indexPath.section == 0 {
           let topCell = tableView.dequeueReusableCell(withIdentifier: "TopCell", for: indexPath)
            
            return topCell
            
            
        } else if indexPath.section == 1 {
            //cell.cellLabel.font = UIFont(name: "MyriadPro-Regular", size: 20)
            let lineView = cell.viewWithTag(2) as! UIView
            lineView.isHidden = false
            switch indexPath.row {
//            case 0:
//                cell.labelText = NSLocalizedString("PROFILE", comment: "")
//                cell.cellLabel.font = UIFont(name: "MyriadPro-Bold", size: 20)
            case 0:
                cell.labelText = NSLocalizedString("EDIT PROFILE", comment: "")
               // cell.cellLabel.font = UIFont(name: "MyriadPro-Bold", size: 20)

            case 1:
                cell.labelText = "Search Connect"
               // cell.cellLabel.font = UIFont(name: "MyriadPro-Bold", size: 20)
            case 2:
                cell.labelText = NSLocalizedString("PASSWORD", comment: "")
                
            case 3:
                cell.labelText = NSLocalizedString("USER_AGREEMENTS", comment: "")
                
            case 5:
                cell.labelText = "\(NSLocalizedString("GDPR", comment: ""))"
                
            case 4:
                cell.labelText = NSLocalizedString("PRIVACY", comment: "")
//
//            case 6:
//                cell.labelText = NSLocalizedString("TELL_A_FRIEND", comment: "")
//
            case 6:
                cell.labelText = "Delete Account"
                
            case 7:
                lineView.isHidden = true
                cell.cellLabel.text = "Log Out"
                
            default:
                break
            }
        }
        cell.backgroundColor = .clear
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return section == 0 ? 25 : 0
//    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        }
        
        if UIDevice.current.screenType == UIDevice.ScreenType.iPhones_6_6s_7_8 { return 50 }
        return UIDevice.current.screenType == UIDevice.ScreenType.iPhones_5_5s_5c_SE ? 45 : 55
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: section == 0 ? 25 : 0))
//
//        return returnedView
//    }
    
    fileprivate func showPrivacy() {
        if let url = URL(string: "https://appin.se/privacysv") {
            if #available(iOS 9.0, *) {
                let safariViewController = SFSafariViewController(url: url)
                present(safariViewController, animated: true, completion: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            // TODO: Statistics send log event for url opened
        }
    }
    
    fileprivate func showUserAgreements() {
        let urlString = "https://appin.se/agreementsv"
        if let url = URL(string: urlString) {
            if #available(iOS 9.0, *) {
                let safariViewController = SFSafariViewController(url: url)
                present(safariViewController, animated: true, completion: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            // TODO: Statistics send log event for url opened
        }
    }
    
    fileprivate func showGDPR(){
        UIApplication.shared.openURL(NSURL(string: "https://appin.se/gdprsv")! as URL)
    }
    
    fileprivate func promptOptOutUser() {
        let alertController = UIAlertController(title: NSLocalizedString("Do you really want to delete an account?", comment: ""), message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Yes", comment: ""), style: UIAlertAction.Style.destructive, handler: { (alertAction: UIAlertAction) in
            //self.reallyOut()
            UserManager.sharedInstance.removeUser({ (user, error) in
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.navigateToLogin()
                }
            })
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("No", comment: ""), style: UIAlertAction.Style.cancel, handler: { (alertAction: UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }

    fileprivate func reallyOut() {
        let alertController = UIAlertController(title: NSLocalizedString("Opting out will delete your profile and make all data generated in the system anonymized in agreement with the iList privacy policy and user agreement", comment: ""), message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Yes", comment: ""), style: UIAlertAction.Style.destructive, handler: { (alertAction: UIAlertAction) in
            UserManager.sharedInstance.removeUser({ (user, error) in
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.navigateToLogin()
                }
            })
        }))
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("No", comment: ""), style: UIAlertAction.Style.cancel, handler: { (alertAction: UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    fileprivate func promptLogoutUser() {
        let alertController = UIAlertController(title: NSLocalizedString("LOGOUT", comment: ""), message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("LOGOUT", comment: ""), style: UIAlertAction.Style.destructive, handler: { (alertAction: UIAlertAction) in
            self.logoutUser()
        }))
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("CANCEL", comment: ""), style: UIAlertAction.Style.cancel, handler: { (alertAction: UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }

    fileprivate func logoutUser() {
        UserManager.sharedInstance.logoutUserWithCompletion {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.navigateToLogin()
                OAuth2Handler.sharedInstance.clearAccessToken()
                
                CustomUserDefault.removeUserId()
                CustomUserDefault.removeLoginData()
                CustomUserDefault.removeUserName()
                CustomUserDefault.removeUserPassword()
                CustomUserDefault.removeTokenTime()
                
                print(OAuth2Handler.hasAccessToken)
            }
        }
    }
    
    fileprivate func showAboutiList() {
        let urlString = NSLocalizedString("URL_WEBSITE", comment: "")
        if let url = URL(string: urlString) {
            if #available(iOS 9.0, *) {
                let safariViewController = SFSafariViewController(url: url)
                present(safariViewController, animated: true, completion: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            // TODO: Statistics send log event for url opened
        }
    }

    fileprivate func presentContactMailComposer() {
        presentMailControllerWithEmail(NSLocalizedString("ILIST_CONTACT_MAIL", comment: ""), subject: nil)
    }
    
    fileprivate func presentMailControllerWithEmail(_ emailAddress:String, subject:String?) {
        let messageComposerController = MFMailComposeViewController(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        messageComposerController.extendedLayoutIncludesOpaqueBars = true
        messageComposerController.mailComposeDelegate = self
        messageComposerController.setToRecipients([emailAddress])
        if let subject = subject{
            messageComposerController.setSubject(subject)
        }
        present(messageComposerController, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
