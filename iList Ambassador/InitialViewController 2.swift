//
//  InitialViewController.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-07-23.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit

protocol VisibilityDelegate: class {
    func showMenu(_ show: Bool)
}

class InitialViewController: UIViewController, VisibilityDelegate {

    fileprivate weak var newProfileViewController: NewProfileViewController!
    fileprivate weak var menuViewController: RotatingMenuViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(excecute(_:)),
                                               name: Notification.Name.init("showMenu"),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MenuSegue", let menuViewController = segue.destination as? RotatingMenuViewController {
            self.menuViewController = menuViewController
            self.menuViewController.view.isHidden = true
            self.menuViewController.delegate = self
        } else if segue.identifier == "RootSegue", let destination = segue.destination as? UINavigationController, let newProfileViewController = destination.topViewController as? NewProfileViewController {
            self.newProfileViewController = newProfileViewController
            self.newProfileViewController.delegate = self
        }
    }
    
    @objc func excecute(_ not: Notification) {
        print("user = \(not.userInfo)")
        if let show = not.userInfo?["data"] as? Bool {
            //menuViewController.view.isHidden = !show
        }
    }

    func showMenu(_ show: Bool) {
         //menuViewController.view.isHidden = !show
    }
}

extension InitialViewController: RotatingMenuViewControllerDelegate, setProfilePicDelegate {
    func showConnections() {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewConnectionsViewController") as! NewConnectionsViewController
        newProfileViewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showBrands() {
        showMenu(false)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BrandsViewController") as! BrandsViewController
        vc.delegate = self
        newProfileViewController.navigationController?.pushViewController(vc, animated: true)
        //let brandConnectViewController = BrandsViewController
        // brandConnectViewController.delegate = ambassadorshipsCollectionViewController
        //present(vc, animated: true)
    }
    
    func showRewards() {
        
    }

    func showProfile() {
        self.newProfileViewController.showProfile()
    }

    func menuAction(segue: String) {
        self.newProfileViewController.menuAction(segue: segue)
    }
    
    func selectedAmbassadorship(ambassadorShip: Ambassadorship) {
        self.newProfileViewController.selectedAmbassadorship(ambassadorShip: ambassadorShip)
    }
    
    func setProfilePictureForMenu(_ image: UIImage) {
        self.menuViewController.setProfilePictureForMenu(image)
    }
}
