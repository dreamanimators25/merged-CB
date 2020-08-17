//
//  ProfileViewController.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 06/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import FontAwesomeKit
import Crashlytics

class ProfileViewController: BaseViewController, AmbassadorshipsCollectionViewControllerDelegate, ProfilePictureImageViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: Views
    @IBOutlet weak var nameLabel: ShadowLabel!
    @IBOutlet weak var profilePictureImageView: ProfilePictureImageView!
    @IBOutlet weak var profilePictureAddIndicator: UIImageView!
    @IBOutlet weak var backgroundImageView: BackgroundImageView!
    
    @IBOutlet weak var inboxButton: InfoButton!
    @IBOutlet weak var connectionsButton: InfoButton!
    @IBOutlet weak var activityButton: InfoButton!
    
    @IBOutlet weak var sendContentButton: InfoButton!
    @IBOutlet weak var connectButton: InfoButton!
    
    var ambassadorshipsCollectionViewController: AmbassadorshipsCollectionViewController?
    
    // MARK: Data
    var user: User?
    var userConnections: [Connection]?
    var deleteIsActive = false
    var tap: UITapGestureRecognizer!
    
    // MARK: Managers
    var profileContentTransitionManager: ProfileContentTransitionManager?
    let imagePicker = UIImagePickerController()
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        automaticallyAdjustsScrollViewInsets = false
        
        profilePictureImageView.delegate = self
        
        backgroundImageView.overlayViewAlpha = 0.6
        
        // Hide all before loading
        inboxButton.isHidden = true
        activityButton.isHidden = true
        connectionsButton.isHidden = true
        sendContentButton.isHidden = true
        connectButton.isHidden = true
        tap = UITapGestureRecognizer(target: self, action: #selector(screenTapped(_:)))
        tap.isEnabled = false
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUserInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hidedeletion()
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    @objc func screenTapped(_ sender: UITapGestureRecognizer) {
        hidedeletion()
    }
    
    // MARK: - User
    
    fileprivate func updateUserInfo() {
        if user == nil {
            user = UserManager.sharedInstance.user
        }
        
        guard let user = self.user else {
            print("No user found in profile")
            return
        }
        
        if user.isCurrentUser {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(settingsButtonTapped(_:)))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close_small"), style: .plain, target: self, action: #selector(closeButtonTapped(_:)))
        }
        
        updateConnectionsForUser(user)
        
        profilePictureImageView.setImageForUser(user)
        backgroundImageView.setBackgroundForUser(user)
        
        nameLabel.text = user.fullName
        profilePictureImageView.allowSelection = user.isCurrentUser
        profilePictureAddIndicator.isHidden = !(user.isCurrentUser && !user.hasProfilePicture)
        
        ambassadorshipsCollectionViewController?.user = user
        
        inboxButton.isHidden = !user.isCurrentUser
        activityButton.isHidden = !user.isCurrentUser
        connectionsButton.isHidden = !user.isCurrentUser
        
        if user.isCurrentUser {
            sendContentButton.isHidden = true
            connectButton.isHidden = true
        } else {
            var isConnectedToUser = false
            //var connectionRequestSentToUser = false
            if let userConnections = UserManager.sharedInstance.connections {
                isConnectedToUser = userConnections.filter({ $0.user.id == user.id }).count > 0
            }
            if let _ = UserManager.sharedInstance.connectionRequests {
                //  connectionRequestSentToUser = userConnectionRequests.filter({ $0.user.id == user.id }).count > 0
            }
            //sendContentButton.hidden = !isConnectedToUser
            sendContentButton.isHidden = true
            connectButton.isHidden = isConnectedToUser
            // TODO: use connectionRequestSentToUser to set connectButton to highlighted if request has been sent
        }
    }
    
    // MARK: - Connections
    
    fileprivate func updateConnectionsForUser(_ user: User) {
        UserManager.sharedInstance.getConnectionsForUser(user) { (connections, error) in
            if let connections = connections {
                self.userConnections = connections
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        }
    }
    
    fileprivate func alertConnectionRequestSent() {
        let alertController = UIAlertController(title: NSLocalizedString("CONNECTION_REQUEST_SENT", comment: ""), message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.cancel, handler: { (alertAction: UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func alertConnectionRequestAlreadySent() {
        let alertController = UIAlertController(title: NSLocalizedString("CONNECTION_REQUEST_ALREADY_SENT", comment: ""), message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.cancel, handler: { (alertAction: UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @objc func settingsButtonTapped(_ sender: AnyObject?) {
        performSegue(withIdentifier: "presentSettingsSegue", sender: sender)
    }
    
    @objc func closeButtonTapped(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func activityButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "showActivitiesSegue", sender: sender)
    }
    
    @IBAction func inboxButtonPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "presentContentInboxSegue", sender: sender)
    }
    
    @IBAction func sendContentButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "showSendContentSegue", sender: sender)
    }
    
    @IBAction func connectButtonTapped(_ sender: AnyObject) {
        let button = sender as! UIButton;
        guard let user = user, let currentUser = UserManager.sharedInstance.user else {
            print("No current user found in profile")
            return
        }
        if !user.isCurrentUser {
            button.isEnabled = false
            UserManager.sharedInstance.createConnectionRequestForUser(currentUser, targetUser: user, completion: { (success, error) in
                if success {
                    self.alertConnectionRequestSent()
                    button.isEnabled = false
                } else if let error = error {
                    if error._code == 400 {
                        self.alertConnectionRequestAlreadySent()
                    }
                    Crashlytics.sharedInstance().recordError(error)
                    button.isEnabled = true
                }
            })
        }
    }
    
    @IBAction func connectionsButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "presentConnectionsSegue", sender: sender)
    }
    
    // MARK: - AmbassadorshipsCollectionViewControllerDelegate
    
    func didTapAddButtonForAmbassadorshipsCollectionViewController(_ ambassadorshipsCollectionViewController: AmbassadorshipsCollectionViewController) {
        let brandConnectViewController = BrandConnectViewController()
        brandConnectViewController.delegate = ambassadorshipsCollectionViewController
        present(brandConnectViewController, animated: true, completion: nil)
    }
    
    func ambassadorshipsCollectionViewController(didSelectCell cell: BrandCollectionViewCell, forAmbassadorship ambassadorship: Ambassadorship) {
        let contentViewController = UIStoryboard(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "ContentController") as! ContentSetupViewController
        contentViewController.ambassadorship = ambassadorship
        
        let logotypeImageViewRect = cell.convert(cell.logotypeImageView.frame, to: self.view)
        let imageView = cell.logotypeImageView
        if let image = imageView.image {
            self.profileContentTransitionManager = ProfileContentTransitionManager(fromBrandImage: image, fromBrandImageViewFrameInViewController: logotypeImageViewRect)
            contentViewController.transitioningDelegate = self.profileContentTransitionManager
        }
        
        present(contentViewController, animated: true, completion: nil)
        imageView.alpha = 0
        delay(1.0, closure: {
            imageView.alpha = 1
        })
    }
    
    func deletionIsActive(_ active:Bool) {
        tap.isEnabled = active
        deleteIsActive = active
    }
    
    func hidedeletion() {
        if deleteIsActive {
            deleteIsActive = false
            tap.isEnabled = false
            if let am = ambassadorshipsCollectionViewController {
                am.shouldWiggle = false
                am.toggleCellWiggle()
            }
        }
    }
    
    // MARK: - ProfilePictureImageViewDelegate
    
    func didTapProfilePictureImageView(_ profilePictureImageView: ProfilePictureImageView) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: UIImage?
        if info[UIImagePickerController.InfoKey.editedImage.rawValue] != nil {
            image = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage
        } else if info[UIImagePickerController.InfoKey.originalImage.rawValue] != nil {
            image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
        }
        if let selectedImage = image {
            didSelectProfilePicture(selectedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func didSelectProfilePicture(_ image: UIImage) {
        let newImage = image.resizeImage(profilePictureImageView.frame.size.width*3)
        profilePictureImageView.startLoading()
        if let user = self.user {
            profilePictureImageView.updateImageForUser(user, image: newImage,completion: { (url) in
                if let url = url, let user = self.user {
                    user.setProfilePicture(url)
                    self.profilePictureImageView.setImageForUser(user)
                    self.profilePictureImageView.allowSelection = false
                    self.profilePictureAddIndicator.isHidden = true
                }
                self.profilePictureImageView.stopLoading()
            })
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentSettingsSegue" {
            if let user = user {
                let navVC = segue.destination as! UINavigationController
                let vc = navVC.viewControllers.first as! SettingsViewController
                vc.user = user
            }
        } else if segue.identifier == "ambassadorshipsCollectionViewControllerContainerSegue" {
            if let ambassadorshipsCollectionViewController = segue.destination as? AmbassadorshipsCollectionViewController {
                ambassadorshipsCollectionViewController.delegate = self
                self.ambassadorshipsCollectionViewController = ambassadorshipsCollectionViewController
            }
        }
    }
}
