//
//  AmbTestViewController.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-08-16.
//  Copyright © 2017 iList AB. All rights reserved.
//
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


class AmbTestViewController: BaseViewController, AmbassadorshipsCollectionViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: Views
    
  
    
    
    var ambassadorshipsCollectionViewController: AmbassadorshipsCollectionViewController?
    
    // MARK: Data
    var user: User?

    private var deleteIsActive = false
    private var tap: UITapGestureRecognizer!
    private let currentUser = UserManager.sharedInstance.user
    
    // MARK: Managers
    var profileContentTransitionManager: ProfileContentTransitionManager?
    let imagePicker = UIImagePickerController()
    // MARK: - View life cycle
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.ilistBackgroundColor()
        automaticallyAdjustsScrollViewInsets = false
        
        
        
        // Hide all before loading
        
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
    
    func screenTapped(_ sender: UITapGestureRecognizer) {
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
            //navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(settingsButtonTapped(_:)))
        } else {
            //navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close_small"), style: .plain, target: self, action: #selector(closeButtonTapped(_:)))
        }
        
        
        
        
        
       
        
        
        ambassadorshipsCollectionViewController?.user = user
        
        
        
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
 
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ambassadorshipsCollectionViewControllerContainerSegue" {
            if let ambassadorshipsCollectionViewController = segue.destination as? AmbassadorshipsCollectionViewController {
                ambassadorshipsCollectionViewController.delegate = self
                self.ambassadorshipsCollectionViewController = ambassadorshipsCollectionViewController
            }
        }
        
    }
}
