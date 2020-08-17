//
//  SettingsViewController.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 16/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI
import FBSDKShareKit


class SettingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, ProfilePictureImageViewDelegate, FBSDKSharingDelegate {

    @IBOutlet weak var tableView: UITableView!
    var profilePictureImageView = ProfilePictureImageView(frame: CGRect.zero)
    var backgroundImageView = SettingsBGPhoto(frame: CGRect.zero)
    
    let imgWidth:CGFloat = 100.0
    
    var bgOverlay:UIView = {
        var frame = SCREENSIZE
        frame.size.height = 100
        let bgOverlay = UIView(frame: frame)
        bgOverlay.isUserInteractionEnabled = false
        bgOverlay.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.font = Font.semiTitleFont(22)
        label.textColor = Color.purpleColor()
        label.text = NSLocalizedString("CHANGE_COVER_PICTURE", comment: "")
        bgOverlay.addSubview(label)
        return bgOverlay
    }()
    
    var profileOverlay:UIView = {
        var frame = SCREENSIZE
        frame.size.height = 100
        let profileOverlay = UIView(frame: frame)
        profileOverlay.isUserInteractionEnabled = false
        profileOverlay.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.font = Font.semiTitleFont(22)
        label.textColor = Color.purpleColor()
        label.text = NSLocalizedString("CHANGE_PROFILE_PICTURE", comment: "")
        profileOverlay.addSubview(label)
        return profileOverlay
    }()
    
    var user:User?
    var currentState: PhotoChangeState = .none
    
    enum PhotoChangeState {
        case profile
        case cover
        case none
    }
    
    final let rows: [String] = [
        NSLocalizedString("ABOUT_ILIST", comment: ""),
        NSLocalizedString("USER_AGREEMENTS", comment: ""),
        NSLocalizedString("CONTACT", comment: ""),
        NSLocalizedString("TELL_A_FRIEND", comment: ""),
        NSLocalizedString("LOGOUT", comment: "")
    ]
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                automaticallyAdjustsScrollViewInsets = false
        
        profilePictureImageView.delegate = self
        profilePictureImageView.tag = 1
        profilePictureImageView.allowSelection = true
        backgroundImageView.delegate = self
        backgroundImageView.tag = 2
        backgroundImageView.allowSelection = true
        if let user = user {
            profilePictureImageView.setImageForUser(user)
            backgroundImageView.setBackgroundForUser(user)
        }
        view.backgroundColor = Color.ilistBackgroundColor()
        tableView.backgroundColor = Color.ilistBackgroundColor()
        
        
        navigationController?.navigationBar.barTintColor = Color.ilistBackgroundColor()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Color.ilistBackgroundColor()]
        navigationItem.rightBarButtonItem = NavigationBar.closeButtonWithTarget(self, action: #selector(closeButtonTapped(_:)))
        navigationItem.rightBarButtonItem?.tintColor = Color.whiteColor()
        navigationItem.title = NSLocalizedString("SETTINGS", comment: "")
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsTableViewCell")
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Actions
    
    @objc func closeButtonTapped(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
    
    func logoutButtonTapped(_ sender: AnyObject?) {
        logoutUser()
    }
    
    // MARK: - User
    
    fileprivate func promptLogoutUser() {
        let alertController = UIAlertController(title: NSLocalizedString("LOGOUT", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("LOGOUT", comment: ""), style: UIAlertActionStyle.destructive, handler: { (alertAction: UIAlertAction) in
            self.logoutUser()
        }))
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("CANCEL", comment: ""), style: UIAlertActionStyle.cancel, handler: { (alertAction: UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func logoutUser() {
        UserManager.sharedInstance.logoutUserWithCompletion {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.navigateToLogin()
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

    
    fileprivate func showUserAgreements() {
        let urlString = NSLocalizedString("URL_AGREEMENTS", comment: "")
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
    
    fileprivate func tellAFriend() {
        let shareLinkString = NSLocalizedString("ILIST_SHARE_LINK", comment: "")
        if let linkUrl = URL(string: shareLinkString) {
            let objectsToShare = [linkUrl, shareLinkString] as [Any]
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.print, UIActivityType.assignToContact]
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - ProfilePictureImageViewDelegate
    
    func didTapProfilePictureImageView(_ profilePictureImageView: ProfilePictureImageView) {
        switch profilePictureImageView.tag {
        case 1:
            currentState = .profile
        case 2:
            currentState = .cover
        default:
            currentState = .none
        }
        present(imagePicker, animated: true, completion: nil)
    }

    
    // MARK: - FBSDKSharingDelegate

    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
        
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
         let alertController = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("NOT_AVAILABLE", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        present(alertController, animated: true, completion: nil)
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        
    }
    
    // MARK: - UITableViewDelegate/UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        cell.textLabel?.font = Font.normalFont(FontSize.Large)
        cell.textLabel?.textColor = Color.whiteColor()
        TableViewStyler.removeSeparatorInsetsForCell(cell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Settings", for: indexPath) as! SettingsCell
        cell.textLabel?.text = rows[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREENSIZE.size.width, height: imgWidth*2+50))
        view.backgroundColor = Color.ilistBackgroundColor()
        var frame = CGRect(x: (view.frame.size.width-imgWidth)/2, y: 20, width: imgWidth, height: imgWidth)
        profilePictureImageView.frame = frame
        
        frame.origin.y += imgWidth+10
        backgroundImageView.frame = frame
        
        var overlayFrame = view.frame
        overlayFrame.size.height = imgWidth
        overlayFrame.origin.y = 20
        profileOverlay.frame = overlayFrame
        
        overlayFrame.origin.y += 110
        bgOverlay.frame = overlayFrame
        
        view.addSubview(profilePictureImageView)
        view.addSubview(backgroundImageView)
        view.addSubview(bgOverlay)
        view.addSubview(profileOverlay)
        
        let botView = UIView(frame: CGRect(x: 0, y: view.frame.size.height-1, width: SCREENSIZE.size.width, height: 1))
        botView.alpha = 0.7
        botView.backgroundColor = Color.lightGrayColor()
        view.addSubview(botView)

        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return imgWidth*2+50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0: showAboutiList()
        case 1: showUserAgreements()
        case 2: presentContactMailComposer()
        case 3: tellAFriend()
        case 4: promptLogoutUser()
        default: break
        }
    }
    
}
