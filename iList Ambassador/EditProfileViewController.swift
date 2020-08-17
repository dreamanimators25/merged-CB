//
//  EditProfileViewController.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-08-20.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI
import FBSDKShareKit

class EditProfileViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, ProfilePictureImageViewDelegate, FBSDKSharingDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
    enum PhotoChangeState {
        case profile
        case cover
        case none
    }
    
    final let rows: [String] = [
                                NSLocalizedString("SHOW WALLET", comment: ""),
                                NSLocalizedString("OVER 21", comment: ""),
                                NSLocalizedString("SHOW CONTENT", comment: ""),
                                NSLocalizedString("SEARCHABLE", comment: ""),
                                NSLocalizedString("GENDER", comment: "")
                                
                                ]
    
    let imagePicker = UIImagePickerController()
    var user:User?
    var currentState: PhotoChangeState = .none
    var profilePictureImageView = ProfilePictureImageView(frame: CGRect.zero)
    var backgroundImageView = SettingsBGPhoto(frame: CGRect.zero)
    let imgWidth:CGFloat = 100.0
    var genderArray = [UIButton]()
    
    var bgOverlay:UIView = {
        var frame = SCREENSIZE
        frame.size.height = 100
        
        let bgOverlay = UIView(frame: frame)
        bgOverlay.isUserInteractionEnabled = false
        bgOverlay.backgroundColor = .clear
        
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.font = Font.semiTitleFont(16)
        label.textColor = Color.ilistBackgroundColor()
        label.text = NSLocalizedString("CHANGE_COVER_PICTURE", comment: "")
        bgOverlay.addSubview(label)
        
        return bgOverlay
    }()
    
    var profileOverlay:UIView = {
        var frame = SCREENSIZE
        frame.size.height = 100

        let profileOverlay = UIView(frame: frame)
        profileOverlay.isUserInteractionEnabled = false
        profileOverlay.backgroundColor = .clear
        
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.font = Font.semiTitleFont(16)
        label.textColor = Color.ilistBackgroundColor()
        label.text = NSLocalizedString("CHANGE_PROFILE_PICTURE", comment: "")
        profileOverlay.addSubview(label)
        
        return profileOverlay
    }()
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func maleButtonPressed(_ sender: UIButton) {
        if sender.alpha == 0.5 {
            genderArray[0].alpha = 1
            genderArray[1].alpha = 0.5
            genderArray[2].alpha = 0.5
        } else {
            sender.alpha = 0.5
        }
        user?.gender = .Male
        updateUserWithGenderButtonStatus(user!, sender: sender)
    }
    
    @IBAction func femaleButtonPressed(_ sender: UIButton) {
        if sender.alpha == 0.5 {
            user?.gender = .Female
            genderArray[0].alpha = 0.5
            genderArray[1].alpha = 1
            genderArray[2].alpha = 0.5
        } else {
            sender.alpha = 0.5
        }
        user?.gender = .Female
        updateUserWithGenderButtonStatus(user!, sender: sender)
    }
    
    @IBAction func noGenderButtonPressed(_ sender: UIButton) {
        if sender.alpha == 0.5 {
            user?.gender = .Unspecified
            genderArray[0].alpha = 0.5
            genderArray[1].alpha = 0.5
            genderArray[2].alpha = 1
        } else {
            sender.alpha = 0.5
        }
        user?.gender = .Unspecified
        updateUserWithGenderButtonStatus(user!, sender: sender)
    }
    
    // TODO: Send signal to change
    @IBAction func switchButtonPressed(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            user?.show_wallet_to_others = !((user?.show_wallet_to_others)!)
        case 1:
            user?.over_21 = !(user?.over_21)!
        case 2:
            user?.show_channels_to_others = !(user?.show_channels_to_others)!
        case 3:
            guard user?.searchable != nil else { return }
            print(user?.searchable!)
            user?.searchable = !(user?.searchable)!
        default:
            break
        }
        updateUserWithSwitchButtonStatus(user!, sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (user == nil) {
            user = UserManager.sharedInstance.user
        }
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .white
        closeButton.imageView?.contentMode = .scaleAspectFit
        
        setupImagePicker()
        setupProfilePictureView()
        setupNavigationItems()
        setupBackgroundImageView()
        
        if let user = user {
            profilePictureImageView.setImageForUser(user)
            backgroundImageView.setBackgroundForUser(user)
        }
        
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
    }
    func getGender(_ user: User, sender: UIButton) -> Bool{
        
        
        switch sender.tag {
        case 3:
            //Male
            if user.gender == .Male {
                sender.alpha = 1
                return true
            }
        case 4:
            if user.gender == .Female {
                sender.alpha = 1
                return true
            }
        case 5:
            if user.gender == .Unspecified {
                sender.alpha = 1
                return true
            }
            
        default:
            break
        }
        return false
    }
    
    // MARK: View setups
    private func setupBackgroundImageView() {
        backgroundImageView.delegate = self
        backgroundImageView.tag = 2
        backgroundImageView.allowSelection = true
    }
    
    private func setupProfilePictureView() {
        profilePictureImageView.delegate = self
        profilePictureImageView.tag = 1
        profilePictureImageView.allowSelection = true
    }
    
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
    }
    private func setupNavigationItems() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = NavigationBar.closeButtonWithTarget(self, action: #selector(closeButtonTapped(_:)))
        navigationItem.rightBarButtonItem?.tintColor = Color.whiteColor()
        
        navigationItem.title = NSLocalizedString("SETTINGS", comment: "")
    }
    
    // MARK: - Actions
    
    
    @objc func closeButtonTapped(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
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
        let alertController = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("NOT_AVAILABLE", comment: ""), preferredStyle: UIAlertController.Style.alert)
        present(alertController, animated: true, completion: nil)
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        
    }
    
    fileprivate func updateUserWithSwitchButtonStatus(_ user: User, sender: UIButton) {
        UserManager.sharedInstance.updateUser(user) { [weak self] (returnedUser: User?, error: Error?) in
            if returnedUser?.id != nil {
                self?.user = returnedUser
                sender.isSelected = !sender.isSelected
            }
        }
        
    }

    fileprivate func updateUserWithGenderButtonStatus(_ user: User, sender: UIButton) {
        UserManager.sharedInstance.updateUser(user) { [weak self] (returnedUser: User?, error: Error?) in
            if returnedUser?.id != nil {
                self?.user = returnedUser
                
            }
        }
        print("Returned user gender:")
        print(self.user?.gender!)
    }
    
    // MARK: - UITableViewDelegate/UITableViewDataSource
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60.0;//Choose your custom row height
    }
    
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
        cell.textLabel?.textColor = Color.ilistBackgroundColor()
        TableViewStyler.removeSeparatorInsetsForCell(cell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Settings", for: indexPath) as! SettingsCell
        cell.maleButton.alpha = 0.5
        cell.femaleButton.alpha = 0.5
        cell.noGenderButton.alpha = 0.5
        
        
        
        switch indexPath.row {
        case 0:
            cell.switchButton?.tag = 0
            cell.switchButton?.imageView?.contentMode = .scaleAspectFit
            cell.switchButton?.isSelected = (user?.show_wallet_to_others)!
            cell.switchButton?.setImage(#imageLiteral(resourceName: "ok-big"), for: .selected)
            cell.switchButton?.setImage(#imageLiteral(resourceName: "Polygon"), for: .normal)
        case 1:
            cell.switchButton?.tag = 1
            cell.switchButton?.imageView?.contentMode = .scaleAspectFit
            cell.switchButton?.isSelected = (user?.over_21)!
            cell.switchButton?.setImage(#imageLiteral(resourceName: "ok-big"), for: .selected)
            cell.switchButton?.setImage(#imageLiteral(resourceName: "Polygon"), for: .normal)
        case 2:
            cell.switchButton?.tag = 2
            cell.switchButton?.imageView?.contentMode = .scaleAspectFit
            cell.switchButton?.isSelected = (user?.show_channels_to_others)!
            cell.switchButton?.setImage(#imageLiteral(resourceName: "ok-big"), for: .selected)
            cell.switchButton?.setImage(#imageLiteral(resourceName: "Polygon"), for: .normal)
        case 3:
            cell.switchButton.tag = 3
            cell.switchButton?.imageView?.contentMode = .scaleAspectFit
            cell.switchButton?.isSelected = (user?.searchable)!
            cell.switchButton?.setImage(#imageLiteral(resourceName: "ok-big"), for: .selected)
            cell.switchButton?.setImage(#imageLiteral(resourceName: "Polygon"), for: .normal)

        case 4:
            cell.maleButton.tag = 3
            cell.maleButton.imageView?.contentMode = .scaleAspectFit
            cell.maleButton.setImage(#imageLiteral(resourceName: "male"), for: .selected)
            cell.maleButton.setImage(#imageLiteral(resourceName: "male"), for: .normal)
            cell.maleButton.isSelected = getGender(user!, sender: cell.maleButton)
            genderArray.append(cell.maleButton)
            
            cell.femaleButton.tag = 4
            cell.femaleButton.imageView?.contentMode = .scaleAspectFit
            cell.femaleButton.setImage(#imageLiteral(resourceName: "female"), for: .selected)
            cell.femaleButton.setImage(#imageLiteral(resourceName: "female"), for: .normal)
            cell.femaleButton.isSelected = getGender(user!, sender: cell.femaleButton)
            genderArray.append(cell.femaleButton)
            
            cell.noGenderButton.tag = 5
            cell.noGenderButton.imageView?.contentMode = .scaleAspectFit
            cell.noGenderButton.setImage(#imageLiteral(resourceName: "no-answer"), for: .selected)
            cell.noGenderButton.setImage(#imageLiteral(resourceName: "no-answer"), for: .normal)
            cell.noGenderButton.isSelected = getGender(user!, sender: cell.noGenderButton)
            genderArray.append(cell.noGenderButton)

        default:
            break
        }
        
        cell.textLabel?.text = rows[indexPath.row]
        
        return cell
    }
    
    // Light up proper button
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREENSIZE.size.width, height: imgWidth*2+50))
        view.backgroundColor = .clear
        var frame = CGRect(x: 10, y: 20, width: imgWidth, height: imgWidth)
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
}

extension EditProfileViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: UIImage?
        if info[UIImagePickerController.InfoKey.editedImage.rawValue] != nil {
            image = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage
        } else if info[UIImagePickerController.InfoKey.originalImage.rawValue] != nil {
            image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
        }
        if let selectedImage = image {
            switch currentState {
            case .profile:
                didSelectProfilePicture(selectedImage)
            case .cover:
                didSelectBackgroundPhoto(selectedImage)
            case .none:
                break
            }
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func didSelectBackgroundPhoto(_ image:UIImage) {
        let newImage = image.resizeImage(SCREENSIZE.size.width*2)
        backgroundImageView.startLoading()
        if let user = self.user {
            backgroundImageView.updateBackgroundImageForUser(user, image: newImage,completion: { (url) in
                if let url = url, let user = self.user {
                    user.setBackgroundPhoto(url)
                    self.backgroundImageView.setBackgroundForUser(user)
                }
                self.backgroundImageView.stopLoading()
            })
        }
    }
    
    fileprivate func didSelectProfilePicture(_ image: UIImage) {
        let newImage = image.resizeImage(profilePictureImageView.frame.size.width*3)
        profilePictureImageView.startLoading()
        if let user = self.user {
            profilePictureImageView.updateImageForUser(user, image: newImage,completion: { (url) in
                if let url = url, let user = self.user {
                    user.setProfilePicture(url)
                    self.profilePictureImageView.setImageForUser(user)
                }
                self.profilePictureImageView.stopLoading()
            })
        }
    }
    
    
}
