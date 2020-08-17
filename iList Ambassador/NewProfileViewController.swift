//
//  NewProfileViewController.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-07-21.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit
import FontAwesomeKit
import Crashlytics
import Alamofire
import FirebaseInstanceID

protocol setProfilePicDelegate: class {
    func setProfilePictureForMenu(_ image: UIImage)
}

extension NewProfileViewController: RotatingMenuViewControllerDelegate {
    
    func showConnections() {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewConnectionsViewController") as? NewConnectionsViewController
    }
    
    func menuAction(segue: String) {
        self.delegate?.setProfilePictureForMenu(self.profilePictureImageView.image!)
        //dismiss(animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: true)
        performSegue(withIdentifier: segue, sender: nil)
    }
    func showRewards() {
        self.delegate?.setProfilePictureForMenu(self.profilePictureImageView.image!)
        navigationController?.popToRootViewController(animated: true)
        setRewardsList((user?.id)!)
    }
    
    func showBrands() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "BrandsViewController")
//        //let brandConnectViewController = BrandsViewController
//        // brandConnectViewController.delegate = ambassadorshipsCollectionViewController
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showProfile() {
        self.delegate?.setProfilePictureForMenu(self.profilePictureImageView.image!)
        navigationController?.popToRootViewController(animated: true)
    }
    func selectedAmbassadorship(ambassadorShip: Ambassadorship) {
        navigationController?.popToRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "contentSegue", sender: ambassadorShip)
    }
    
 
}

class NewProfileViewController: BaseViewController, ProfilePictureImageViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: Views
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var backgroundImageView: BackgroundImageView!
    @IBOutlet weak var nameLabel: ShadowLabel!
    @IBOutlet weak var profilePictureImageView: ProfilePictureImageView! {
        didSet {
            //delegate?.setProfilePictureForMenu(#imageLiteral(resourceName: "close"))
            //delegate?.setProfilePictureForMenu(profilePictureImageView.image!)
        }
    }
    @IBOutlet weak var profilePictureAddIndicator: UIImageView!
    @IBOutlet weak var inboxButton: InfoButton!
    @IBOutlet weak var connectionsButton: InfoButton!
    @IBOutlet weak var activityButton: InfoButton!
    @IBOutlet weak var sendContentButton: InfoButton!
    @IBOutlet weak var connectButton: InfoButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var rewardsButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var contentButton: UIButton!
    
    var ambassadorship: [Ambassadorship]?
    
    var delegate: setProfilePicDelegate?
    
    var ambassadorshipsCollectionViewController: AmbassadorshipsCollectionViewController?
    
    // MARK: Data
    var user: User?
    func checkFriends() -> Bool {
        //Checks userConnections to see if user.id is in list
        for x in userConnections! {
            if x.toUser.id == currentUser?.id && x.fromUser.id == user?.id {
                return true
            }
        }
        return false
    }
    private var userConnections: [Connection]? {
        didSet {
            if user?.id != 0 {
                if (user?.isCurrentUser)! {
                    setRewardsAndBadges((currentUser?.id)!)
                    setRewards = true
                } else { checkFriends() ? setRewardsAndBadges((user?.id)!) : ()
                    setRewards = true
                }
            }
        }
    }
    
    private var deleteIsActive = false
    private var tap: UITapGestureRecognizer!
    private var rewardsArray = [RewardList]()
    private var badgeArray = [Badge]()
    private var badgeImage: UIImage?
    private var iconImage: UIImage?
    private var levelBadgeArray: [Bool]?
    private var levelarray: [Bool]?
    private var influencerBadgeArray: [Bool]?
    private let currentUser = UserManager.sharedInstance.user
    fileprivate var setRewards = false
    
    // MARK: Managers
    var profileContentTransitionManager: ProfileContentTransitionManager?
    let imagePicker = UIImagePickerController()
    // MARK: - View life cycle
    
    public func getProfileImage() -> ProfilePictureImageView{
        return profilePictureImageView
        delegate?.setProfilePictureForMenu(profilePictureImageView.image!)
    }
    
    private func setRewardsAndBadges(_ userId: Int) {
        setRewardsList(userId)
        setBadgeList(userId)
        setLevelBadgeList(userId)
        setInfluencerBadgeList(userId)
    }
    
    private func setButtonAspectRatio() {
        rewardsButton.imageView?.contentMode = .scaleAspectFit
        searchButton.imageView?.contentMode = .scaleAspectFit
        inboxButton.imageView?.contentMode = .scaleAspectFit
        settingsButton.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        closeButton.isHidden = true
        contentButton.imageView?.contentMode = .scaleAspectFit
        connectButton.imageView?.contentMode = .scaleAspectFit
        
        automaticallyAdjustsScrollViewInsets = false
        
        profilePictureImageView.delegate = self
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        // Hide all before loading
        rewardsButton.isHidden = true
        inboxButton.isHidden = true
        activityButton.isHidden = true
        connectionsButton.isHidden = true
        sendContentButton.isHidden = true
        connectButton.isHidden = true
        
        tap = UITapGestureRecognizer(target: self, action: #selector(screenTapped(_:)))
        tap.isEnabled = false
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.token = InstanceID.instanceID().token()
        if let id = UserManager.sharedInstance.user?.id, let token = AppDelegate.token {
            let router = UserRouter(endpoint: .updatePushToken(token: token, userId: "\(id)"))
            UserManager.sharedInstance.performRequest(withRouter: router) { (data) in
                print("data = \(data)")
            }
        }
        
        //print("user = \(UserManager.sharedInstance.user?.id), token = \( AppDelegate.token)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUserInfo()
        delegate?.setProfilePictureForMenu(profilePictureImageView.image!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //hidedeletion()
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    @objc func screenTapped(_ sender: UITapGestureRecognizer) {
        //hidedeletion()
    }
    
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
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
            //navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(settingsButtonTapped(_:)))
            
            
        } else {
            // TODO: Check if user has hide content flag before displaying. Make checks their own functions returning the bool straight from user meta.
            closeButton.isHidden = true
            settingsButton.isHidden = true
            rewardsButton.isHidden = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(closeButtonTapped(_:)))
            if user.show_channels_to_others! {
                contentButton.isHidden = false
            }
            if user.show_wallet_to_others! {
                rewardsButton.isHidden = false
            }
        }
        
        
        setButtonAspectRatio()
        backgroundImageView.setBackgroundForUser(user)
        updateConnectionsForUser(user)
        
        profilePictureImageView.setImageForUser(user)
        
        self.delegate?.setProfilePictureForMenu(self.profilePictureImageView.image!)
            /*while true {
                if self.profilePictureImageView.image == #imageLiteral(resourceName: "profile") {
                    print("NOT YET SET")
                    sleep(5)
                } else {
                    print("NOW SET")
                    self.delegate?.setProfilePictureForMenu(self.profilePictureImageView.image!)
                    sleep(2)
                }
            }*/
        
        
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
            searchButton.isHidden = true
            var isConnectedToUser = false
            //var connectionRequestSentToUser = false
            if let userConnections = UserManager.sharedInstance.connections {
                isConnectedToUser = userConnections.filter({ $0.user.id == user.id }).count > 0
            }
            if !isConnectedToUser {
                rewardsButton.isHidden = true
                contentButton.isHidden = true
                
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
    
    // MARK: - Rewards list
    
    func setLevelBadgeList(_ id: Int) {
        RewardManager.sharedInstance.getLevelBadges(id) { (badges, error, success) in
            if success == true  {
                DispatchQueue.main.async(execute: { 
                    self.levelBadgeArray = badges!
                })
            }
        }
    }
    
    func setInfluencerBadgeList(_ id: Int) {
        RewardManager.sharedInstance.getInfluencerBadges(id) { (badges, error, success) in
            if success == true && (badges?.count)! > 0 {
                DispatchQueue.main.async(execute: { 
                    self.influencerBadgeArray = badges!
                })
            }
        }
    }
    
    func setRewardsList(_ id: Int) {
        RewardManager.sharedInstance.getRewardsForId(id) { (rewards, error, success) in
            if success == true && (rewards?.count)! > 0 {
                DispatchQueue.main.async(execute: { 
                    self.rewardsArray = rewards!
                    for object in self.rewardsArray {
                        self.setRewardsListImg(object.iconUrl.absoluteString)
                    }
                })
            }
        }
    }
    
    func setBadgeList(_ id: Int) {
        RewardManager.sharedInstance.getBadges(id) { (badges, error, success) in
            if success == true && (badges?.count)! > 0 {
                DispatchQueue.main.async(execute: { 
                    self.badgeArray = badges!
                    for object in self.badgeArray {
                        self.setBadgeImg(object.brandBadge.badge)
                    }
                })
                
            }
        }
    }
    fileprivate func setBadgeImg(_ imgString: URL) {
        Alamofire.request(imgString).responseImage { response in
            DispatchQueue.main.async(execute: { 
                if let imageResult = response.result.value {
                    self.badgeImage = (imageResult)
                }
            })
            
        }
    }
    
    
    fileprivate func setRewardsListImg(_ imgString: String) {
        Alamofire.request(imgString).responseImage { response in
            DispatchQueue.main.async(execute: { 
                if let imageResult = response.result.value {
                    self.iconImage = (imageResult)
                }
            })
            
        }
    }

    
    // MARK: - Connections
    
    fileprivate func updateConnectionsForUser(_ user: User) {
        UserManager.sharedInstance.getConnectionsForUser(user) { (connections, error) in
            if let connections = connections {
                self.userConnections = connections
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
                print("Connection down so updating friends list failed, as it should")
                //self.userConnections?.append(Connection(dictionary: ["firstName" : "Empty"]))
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
    
    
    
    
    
    
    @IBAction func showContent(_ sender: UIButton) {
        performSegue(withIdentifier: "presentConnectionsSegue", sender: sender)
    }
    
    @IBAction func rewardsBUttonTapped(_ sender: UIButton) {
        showRewards()
        if self.rewardsArray != nil {
            self.performSegue(withIdentifier: "rewardsSegue", sender: self)
        }
    }
    
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "presentSettingsSegue", sender: sender)
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        //performSegue(withIdentifier: "presentConnectionsSegue", sender: sender)
        performSegue(withIdentifier: "searchSegue", sender: sender)
    }
    
    /*func settingsButtonTapped(_ sender: AnyObject?) {
        performSegue(withIdentifier: "presentSettingsSegue", sender: sender)
    }*/
    
    @IBAction func closeButtonTapped(_ sender: AnyObject?) {
       dismiss(animated: true, completion: nil)
    }
    
    @IBAction func activityButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "showActivitiesSegue", sender: sender)
    }
    
    @IBAction func inboxButtonPressed(_ sender: AnyObject) {
        ContentManager.sharedInstance.getSharedContent((self.currentUser?.id)!, completion: {contents, error in
            if let contents = contents {
                
                //let singleInboxElement = contents[0]
                let contentViewController = UIStoryboard(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "ContentController") as! ContentSetupViewController
                //contentViewController.content = singleInboxElement
                contentViewController.fromInbox = true
                contentViewController.contents = contents
                contentViewController.contentArray = contents
                //if let imgString = singleInboxElement.pages[0].backgrounds?.file_url {
                //contentViewController.setBrandImg(imgString)
                //}
                //self.present(contentViewController, animated: true, completion: nil)
                self.show(contentViewController, sender:nil)
 
                
                }
            })

        
        //performSegue(withIdentifier: "presentContentInboxSegue", sender: sender)
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
            let vc = segue.destination as! SettingsTableViewController
            vc.user = user
        }
        else if segue.identifier == "presentConnectionsSegue" {
            let navVC = segue.destination as! ConnectionsViewController
            navVC.user = user
        }else if segue.identifier == "OLDpresentSettingsSegue" {
            if let user = user {
                let navVC = segue.destination as! UINavigationController
                let vc = navVC.viewControllers.first as! EditProfileViewController
                vc.user = user
            }
        }else if segue.identifier == "contentSegue", let dest = segue.destination as? ContentSetupViewController, let ship = sender as? Ambassadorship {
            guard user != nil, user?.id != 0 else { return }
            dest.ambassadorship = ship
            dest.user = user
            
            let url = ship.brand.logotypeUrl
            dest.setBrandImg(url)

        } else if segue.identifier == "rewardsSegue" {
            let dest = segue.destination as! UINavigationController
            let destination = dest.viewControllers.first as! RewardsSetupViewController
            destination.user = user
            destination.rewardsArray = self.rewardsArray
            destination.badgeArray = self.badgeArray
            destination.levelBadgeArray = self.levelBadgeArray
            destination.influencerBadgeArray = self.influencerBadgeArray
        }  else if segue.identifier == "presentContentInboxSegue" {
            let destination = segue.destination as! ContentInboxViewController
            destination.user = user
        }
    }
}

extension UIViewController {
    
    func setBackButton(){
        
        let yourBackImage = #imageLiteral(resourceName: "close")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
    }
}

