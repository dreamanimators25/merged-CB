//
//  ProfileViewController.swift
//  iList Ambassador
//
//  Created by Dmitriy Zhyzhko on 24.02.2019.
//  Copyright © 2019 iList AB. All rights reserved.
//

import UIKit

protocol FriendsTableViewCellResultDelegate {
    func changeReq()
    func changeCon()
}

final class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var typeButton: UIButton!
    
    var connections: [Connection]?
    var myConnection: Connection?
    
    var connect: Connection?
    var connectRequest: ConnectionRequest?
    
    var user: User?
    var plus: Bool?
    var isPlus = true
    
    var del: FriendsTableViewCellResultDelegate?
    
    var delegate1: FriendsTableViewCellDelegate1?
    var delegate2: FriendsTableViewCellDelegate2?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("plus = \(plus)")
        
        if let plus = plus {
            if plus == false {
                typeButton.setImage(UIImage(named: "deletefriend1"), for: .normal)
            }
        }
        
        if let user = user {
            typeButton.isHidden = user.isCurrentUser 
            setImageForUser(user)
            nameLabel.text = "\(user.firstName) \(user.lastName)"
        }
        
        print("conecc = \(user?.id)")
       
        typeButton.isHidden = true
        
        if connect == nil && connectRequest == nil  {
        UserManager.sharedInstance.getConnectionsForUser(UserManager.sharedInstance.user!) { (conn, err) in
            if let conn = conn {
                self.connections = []
                self.connections?.append(contentsOf: conn)
                if let contains = self.connections?.filter({ (c) -> Bool in
                    return self.user!.id == c.fromUser.id
                }).first {
                    self.myConnection = contains
                    self.isPlus = false
                    self.typeButton.setImage(UIImage(named: "deletefriend1"), for: .normal)
                }
            }
            self.typeButton.isHidden = self.user!.isCurrentUser
        }
        } else {
             self.typeButton.isHidden = self.user!.isCurrentUser
        }
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
    }
    
    func setImageForUser(_ user: User) {
        if let profileImageUrlString = user.profileImage, let profileImageUrl = URL(string: profileImageUrlString) {
            setImageFromUrl(profileImageUrl)
        } else {
            setDefaultImageForUser(user)
        }
    }
    
    func setDefaultImageForUser(_ user: User) {
        imageView.af_cancelImageRequest()
        imageView.image = user.defaultImage()
        imageView.backgroundColor = Color.backgroundColorFadedDark()
    }
    
    func setImageFromUrl(_ url: URL) {
        imageView.af_setImage(withURL: url)
    }
    
    @IBAction func onButtonPressed(_ sender: Any) {
        if let plus = plus {
            if (plus == true) {
                
                delegate1?.plusPressed(user: connectRequest)
            } else {
                delegate2?.minusPressed(user: connect)
            }
            typeButton.isHidden = true
        } else {
            typeButton.isEnabled = false
            
            if (self.isPlus) {
            UserManager.sharedInstance.createConnectionRequestForUser(UserManager.sharedInstance.user!,
                                                                      targetUser: user!, completion: { (success, error) in
                if success {
                    //self.alertConnectionRequestSent()
                    self.typeButton.isHidden = true
                } else if let error = error {
                    self.typeButton.isEnabled = true
                }
            })
            } else {
                removeConnection()
            }
        }
    }
    
    fileprivate func removeConnection() {
        guard let user = UserManager.sharedInstance.user, let con = myConnection else {
            print("User not found in ConnectionsTableViewController")
            return
        }
        UserManager.sharedInstance.deleteConnectionForUser(user, connection: con) { (connection, error) in
             self.typeButton.isHidden = true
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
