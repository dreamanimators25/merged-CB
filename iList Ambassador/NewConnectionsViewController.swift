//
//  NewConnectionsViewController.swift
//  iList Ambassador
//
//  Created by Dmitriy Zhyzhko on 10.03.2019.
//  Copyright © 2019 iList AB. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

protocol FriendsTableViewCellDelegate1 {
    func plusPressed(user: ConnectionRequest?)
    func minusPressed(user: ConnectionRequest?)
    func pressed(user: ConnectionRequest?, plus: Bool)
}

protocol FriendsTableViewCellDelegate2 {
    func plusPressed(user: Connection?)
    func minusPressed(user: Connection?)
    func pressed(user: Connection?, plus: Bool)
    
    func removeGroup(cell: FriendsTableViewCell)
}

protocol SimpleDelegate {
    func updateAll()
}


final class NewConnectionsViewController: UIViewController, FriendsTableViewCellDelegate1, FriendsTableViewCellDelegate2, SimpleDelegate {
    
    func removeGroup(cell: FriendsTableViewCell) {
        
        let alertController = UIAlertController(title: nil, message: "Do you want to remove this group?", preferredStyle: UIAlertController.Style.alert)
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { (action: UIAlertAction) in
                
                let indexPath = self.friendsTableView.indexPath(for: cell)
                print(indexPath?.row ?? 0)
                self.removeSelectedGroup(index: indexPath?.row ?? 0)
                
                alertController.dismiss(animated: true)
            }))
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: { (action: UIAlertAction) in
                alertController.dismiss(animated: true)
            }))
            
            present(alertController, animated: true)
    
    }
    
   
    @IBOutlet weak var friendsTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var requestsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var friendsTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var requestlable: UILabel!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var requestTableView: UITableView!
    
    fileprivate var cellSize: CGFloat = 85
    
    fileprivate let user = UserManager.sharedInstance.user
    fileprivate var ambassadorships: [Ambassadorship] = []
    
    var revokIndex = -1
    
    var connectionsSearch = [Connection] ()
    
    var arrGroupData = [GroupList]()
    
    var connections: [Connection]? {
        didSet {
            if connections?.count == 0 {
                friendsTopConstraint.constant = 0
            }
            friendsTableViewHeight.constant = CGFloat(80 *
                (connections?.count ?? 0))
            del2.connections = connections
//            if (connections?.count != 0) {
//                friendsLabel.isHidden = false
//            } else {
//                friendsLabel.isHidden = true
//            }
            self.friendsTableView.reloadData()
            //print("From user: \(String(describing: connections?[0].fromUser.id))")
            //print("To user: \(String(describing: connections?[0].toUser.id))")
            //del1.connections = connections
            //self.requestTableView.reloadData()
        }
    }
    
    var connectionRequests: [ConnectionRequest]? {
        didSet {
            requestsTableViewHeight.constant = CGFloat(80 *
                (connectionRequests?.count ?? 0 ))
            del1.connections = connectionRequests
            if (connectionRequests?.count != 0) {
                requestlable.isHidden = false
            } else {
                requestlable.isHidden = true
            }
            self.requestTableView.reloadData()
           // self.requestTableView.reloadData()
        }
    }
    
    let del1 = RequestsDataSource()
    let del2 = FriendsDataSource()
    
    func updateAll() {
//        updateConnections()
//        updateConnectionRequests()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateConnectionRequests()
        //updateConnections()
        getGroupDetails()
    }
    
    func getGroupDetails() {
        
        /*
        let head : HTTPHeaders = ["Auth" : "Bearer " + (Keychain.loadAccessToken() ?? "")]
        print(head)
        
        Alamofire.request(newBaseURL + "users/\(user?.id ?? 0)/groups", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: head).responseJSON { (respo) in
            print(respo)
        }*/
        
        
        guard let user = UserManager.sharedInstance.user else {
            print("User not found in ConnectionRequestsViewController")
            return
        }
        
        UserManager.sharedInstance.getGroupDetails(user) { (responseData) in
            print(responseData ?? [])
         
            if let arrData = responseData {
                self.arrGroupData = []
                
                for item in arrData {
                    let json = JSON(item)
                    print(json)
                    
                    let responsModal = GroupList.init(json: json)
                    self.arrGroupData.append(responsModal)
                    
                }
                
                self.loadGroupList()
                
            }else {
                self.showAlertWithTitle(NSLocalizedString("Something went wrong.", comment: ""), message: nil, completion: {
                    
                })
            }
        }
    }
    
    func loadGroupList() {
        if arrGroupData.count == 0 {
            friendsTopConstraint.constant = 0
        }

        friendsTableViewHeight.constant = CGFloat(80 *
            (arrGroupData.count ))
        del2.arrData = arrGroupData
        self.friendsTableView.reloadData()
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.init("showMenu"), object: nil, userInfo: ["data" : true])
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onGroupAddPressed(_ sender: Any) {
        
        let alertController = UIAlertController(title: "", message: "Please Enter Referrel code!", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Referrel Code"
        }
        
        let saveAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { alert -> Void in
            
            self.addGroup(Code: alertController.textFields![0].text ?? "")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //S
    private func addGroup(Code:String) {
        
        let url = newBaseURL + "users/\(user?.id ?? 0)/groups/\(Code)/"
        
        let head = ["Authorization" : "Bearer " + (Keychain.loadAccessToken() ?? "")]
        
        Alamofire.request(url, method: .post, encoding: JSONEncoding.default, headers: head).responseJSON { (response) in
            
            guard response.result.error == nil else {
                self.showAlertWithTitle(NSLocalizedString("Something went wrong.", comment: ""), message: nil, completion: {
                    
                })
                return
            }
            
            //var dict = response.result.value as! [String:Any]
            //print(dict)
            //dict["group_name"] = Code
            
            self.getGroupDetails()
        }
    }
    
    func removeSelectedGroup(index:Int) {
        let item = arrGroupData[index]
        let url = newBaseURL + "brands/\(item.brandId ?? 0)/groups/\(item.groupId ?? 0)/ambassadors/"
        print(url)
        
        let head = ["Authorization" : "Bearer " + (Keychain.loadAccessToken() ?? "")]
        print(head)
        
        let param = ["type" : "delete",
                     "ambassadorship_ids" : [item.ambassadorshipsId ?? 0]] as [String : Any]
        print(param)
        
        Alamofire.request(url, method: .post,parameters: param,encoding: JSONEncoding.default, headers: head).responseJSON { (response) in
            
            guard response.result.error == nil else {
                self.showAlertWithTitle(NSLocalizedString("Something went wrong.", comment: ""), message: nil, completion: {
                    
                })
                return
            }
            
            self.getGroupDetails()
            
        }
    }
    
    @IBAction func onSearchPressed(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        vc.delegateAll = self
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBOutlet weak var left: NSLayoutConstraint!
    
    @IBOutlet weak var right: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        requestTableView.dataSource = del1
        requestTableView.delegate = del1
        friendsTableView.delegate = del2
        friendsTableView.dataSource = del2
        
        scrollView.delegate = self
        
        del1.delegate = self
        del2.delegate = self
        self.makeBarButton()
        
        scrollView.contentInset = UIEdgeInsets(top:  35, left: 0, bottom: 0, right: 0)
        getAmbassadorshipsForUser()
        
        if UIDevice.current.screenType == UIDevice.ScreenType.iPhones_6_6s_7_8 {
            cellSize = 72
            scrollView.contentInset = UIEdgeInsets(top:  10, left: 0, bottom: 0, right: 0)
        } else if UIDevice.current.screenType == UIDevice.ScreenType.iPhones_5_5s_5c_SE {
            left.constant -= 20
            right.constant -= 20
            cellSize = 60
            scrollView.contentInset = UIEdgeInsets(top:  10, left: 0, bottom: 0, right: 0)
        } else  if UIDevice.current.screenType == UIDevice.ScreenType.iPhoneX {
            left.constant -= 10
            right.constant -= 10
            cellSize = 70
            //scrollView.contentInset = UIEdgeInsets(top:  10, left: 0, bottom: 0, right: 0)
        }
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.5
        longPressGR.numberOfTouchesRequired = 1
        longPressGR.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(longPressGR)
    
      
        NotificationCenter.default.post(name: Notification.Name.init("showMenu"), object: nil, userInfo: ["data" : false])
        //collectionViewHeightConstraint.constant = 800
    }
    
    
    func makeBarButton()
    {
        self.makeNavigationBar()
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "left-arrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        let barButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.leftBarButtonItem = barButton
    }
    @objc func closeButtonTapped(_ sender: AnyObject?) {
        NotificationCenter.default.post(name: Notification.Name.init("showMenu"), object: nil, userInfo: ["data" : true])
        navigationController?.popViewController(animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    
    func pressed(user: Connection?, plus: Bool) {
        print("plus = \(plus)")
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc.connect = user
        vc.user = user?.toUser
        vc.plus = plus
        vc.delegate1 = self
        vc.delegate2 = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pressed(user: ConnectionRequest?, plus: Bool) {
        print("plus = \(plus)")
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc.connectRequest = user
        vc.user = user?.toUser
        vc.plus = plus
        vc.delegate1 = self
        vc.delegate2 = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func plusPressed(user: Connection?) {
        
    }
    
    func minusPressed(user: Connection?) {
        if let user = user {
            removeConnection(user)
            if let index = connections?.firstIndex(where: { (request) -> Bool in
                return user.id == request.id
            }) {
                connections?.remove(at: index)
                friendsTableView.reloadData()
                //requestTableView.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .fade)
            }
        }
    }
    
    func plusPressed(user: ConnectionRequest?) {
        if let user = user {
            acceptConnectionRequest(user)
            if let index = connectionRequests?.firstIndex(where: { (request) -> Bool in
                return user.id == request.id
            }) {
                connectionRequests?.remove(at: index)
                requestTableView.reloadData()
                //requestTableView.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .fade)
            }
        }
    }
    
    func minusPressed(user: ConnectionRequest?) {
        if let user = user {
            declineConnectionRequest(user)
            if let index = connectionRequests?.firstIndex(where: { (request) -> Bool in
                return user.id == request.id
            }) {
                connectionRequests?.remove(at: index)
                requestTableView.reloadData()
                //requestTableView.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .fade)
            }
        }
    }
    
    fileprivate func removeConnection(_ connection: Connection) {
        guard let user = UserManager.sharedInstance.user else {
            print("User not found in ConnectionsTableViewController")
            return
        }
        UserManager.sharedInstance.deleteConnectionForUser(user, connection: connection) { (connection, error) in
            //self.updateConnections()
        }
    }
    
    fileprivate func acceptConnectionRequest(_ connectionRequest: ConnectionRequest) {
        guard let user = UserManager.sharedInstance.user else {
            print("User not found in ConnectionRequestsViewController")
            return
        }
        UserManager.sharedInstance.updateConnectionRequestForUser(user, connectionRequest: connectionRequest, connectionRequestAction: ConnectionRequestAction.Accept) { (connectionRequest, error) in
            if let _ = connectionRequest {
                self.updateConnectionRequests()
                //self.updateConnections()
            } else if let error = error {
                // Crashlytics.sharedInstance().recordError(error)
            }
        }
    }
    
    fileprivate func declineConnectionRequest(_ connectionRequest: ConnectionRequest) {
        guard let user = UserManager.sharedInstance.user else {
            print("User not found in ConnectionRequestsViewController")
            return
        }
        UserManager.sharedInstance.updateConnectionRequestForUser(user, connectionRequest: connectionRequest, connectionRequestAction: ConnectionRequestAction.Reject) { (connectionRequest, error) in
            if let _ = connectionRequest {
                self.updateConnectionRequests()
                //self.updateConnections()
            } else if let error = error {
                // Crashlytics.sharedInstance().recordError(error)
            }
        }
    }
    
    private func getAmbassadorshipsForUser() {
        AmbassadorshipManager.sharedInstance.getAmbassadorshipsForUser(user!.id, page: 1, pageSize: 20) { [weak self] (ambassadorships, error) in
            if let ambassadorships = ambassadorships {
                self?.ambassadorships = ambassadorships
                let rows = Double(self!.ambassadorships.count + 1) / Double(3)
                print("rows = \(rows)")
                self?.collectionViewHeightConstraint.constant = CGFloat(ceil(rows) * 85)
                self?.collectionView?.reloadData()
            } else if let error = error {
          
            }
        }
    }
    
    fileprivate func cancelConnectionRequest(_ connectionRequest: ConnectionRequest) {
        guard let user = UserManager.sharedInstance.user else {
            print("User not found in ConnectionRequestsViewController")
            return
        }
        UserManager.sharedInstance.updateConnectionRequestForUser(user, connectionRequest: connectionRequest, connectionRequestAction: ConnectionRequestAction.Cancel) { (connectionRequest, error) in
            if let _ = connectionRequest {
                self.updateConnectionRequests()
                //self.updateConnections()
            } else if let error = error {
                //Crashlytics.sharedInstance().recordError(error)
            }
        }
    }
    
    
    fileprivate func updateConnections() {
        UserManager.sharedInstance.getConnectionsForUser(user!, completion: { (connections, error) in
            if let connections = connections {
                self.connections = connections
                //                let c = Connection.init()
                //                self.connections?.append(c)
            } else if let error = error {
                // self.friendsLabel.isHidden = true
                // Crashlytics.sharedInstance().recordError(error)
            } else {
                 //self.friendsLabel.isHidden = true
            }
//            self.connections = [Connection] ()
//            let c = Connection.init()
//            self.connections?.append(c)
        })
        //self.requestTableView.reloadData()
    }
    
    fileprivate func updateConnectionRequests() {
       
        UserManager.sharedInstance.getConnectionRequestForUser(user!, completion: { (connectionRequests, error) in
            if let connectionRequests = connectionRequests {
                self.connectionRequests = connectionRequests.filter({ !$0.requestRejected })
//                let c = ConnectionRequest.init()
//                self.connectionRequests?.append(c)
                if self.connectionRequests?.count == 0 {
                    self.friendsTopConstraint.constant = -20
                    self.requestsTableViewHeight.constant = 0
                }
            } else if let error = error {
               // Crashlytics.sharedInstance().recordError(error)
                self.friendsTopConstraint.constant = -20
                 self.requestsTableViewHeight.constant = 0
                self.requestlable.isHidden = true
            } else {
                self.friendsTopConstraint.constant = -20
                self.requestsTableViewHeight.constant = 0
                self.requestlable.isHidden = true
            }
        })
    }
    
    func showRemoveDialog(connection: Ambassadorship) {
        let message = String(format: NSLocalizedString("REVOKE_AMBASSDORSHIP_MESSAGE", comment: ""), connection.brand.name)
        let alertController = UIAlertController(title: nil, message: "Do you want to opt out of the channel?", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { (action: UIAlertAction) in
            self.revokeAmbassadorship(connection)
            alertController.dismiss(animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: { (action: UIAlertAction) in
            alertController.dismiss(animated: true)
        }))
        
        present(alertController, animated: true)
    }
    
    private func revokeAmbassadorship(_ ambassadorship: Ambassadorship) {
        AmbassadorshipManager.sharedInstance.revokeAmbassadorship(ambassadorship, completion: { [weak self] (error: Error?) in
            if let _ = error {
                self?.showErrorAlert(withMessage: "Error revoking ambassadorship")
            } else {
                if let rev = self?.revokIndex, rev != -1 {
                    NotificationCenter.default.post(name: Notification.Name.init("reloadAmbasadro"), object: nil, userInfo: nil)
                    self?.ambassadorships.remove(at: rev)
                    self?.collectionView.reloadData()
                }
            }
        })
    }
}

class FriendsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, FriendsTableViewCellDelegate2 {
    
    
    func removeGroup(cell: FriendsTableViewCell) {
        delegate?.removeGroup(cell: cell)
    }
    
    
    var connections: [Connection]?
    var delegate: FriendsTableViewCellDelegate2?
    
    var arrData : [GroupList]?
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return connections?.count ?? 0
        return arrData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as! FriendsTableViewCell
        
        if let item = arrData?[indexPath.row] {
            cell.nameLabel.text = item.groupName
            cell.profileImageView.isHidden = true
            cell.imageWidhtConstraint.constant = 0
        }
        
        /*
        if let item = connections?[indexPath.row] {
            cell.connect = item
            cell.nameLabel.text = "\(item.toUser.fullName)"
            cell.profileImageView.clipsToBounds = true
            cell.profileImageView.contentMode = .scaleAspectFill
            cell.profileImageView.layer.cornerRadius =  cell.profileImageView.frame.width / 2
            
            if let profileImageUrlString = item.toUser.profileImage, let profileImageUrl = URL(string: profileImageUrlString) {
                cell.profileImageView.af_setImage(withURL: profileImageUrl)
            } else {
                cell.profileImageView.af_cancelImageRequest()
                cell.profileImageView.image = item.toUser.defaultImage()
                cell.profileImageView.backgroundColor = Color.backgroundColorFadedDark()
            }
        }*/
        
        cell.selectionStyle = .none
        cell.plusButton.isHidden = true
        cell.delegate2 = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        if let user = connections?[indexPath.row] {
            pressed(user: user, plus: false)
        }*/
    }
    
    func pressed(user: Connection?, plus: Bool) {
        //delegate?.pressed(user: user, plus: false)
    }
    
    func plusPressed(user: Connection?) {
        //delegate?.plusPressed(user: user)
    }
    
    func minusPressed(user: Connection?) {
        //delegate?.minusPressed(user: user)
    }
    
}

class RequestsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, FriendsTableViewCellDelegate1 {
    
    var connections: [ConnectionRequest]?
    var delegate: FriendsTableViewCellDelegate1?
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as! FriendsTableViewCell
        cell.selectionStyle = .none
        if let item = connections?[indexPath.row] {
            cell.connectRequest = item
            cell.nameLabel.text = "\(item.toUser.fullName)"
            cell.profileImageView.clipsToBounds = true
            cell.profileImageView.contentMode = .scaleAspectFill
            cell.profileImageView.layer.cornerRadius =  cell.profileImageView.frame.width / 2
            
            if let profileImageUrlString = item.toUser.profileImage, let profileImageUrl = URL(string: profileImageUrlString) {
                cell.profileImageView.af_setImage(withURL: profileImageUrl)
            } else {
                cell.profileImageView.af_cancelImageRequest()
                cell.profileImageView.image = item.toUser.defaultImage()
                cell.profileImageView.backgroundColor = Color.backgroundColorFadedDark()
            }
        }
        print("index ROW = \(indexPath.row)")
        cell.plusButton.tag = indexPath.row
        //cell.plusButton.addTarget(self, action: #selector(pressed(_:)), for: .touchDown)
        cell.delegate1 = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = connections?[indexPath.row] {
            pressed(user: user, plus: true)
        }
    }
    
    func pressed(user: ConnectionRequest?, plus: Bool) {
        delegate?.pressed(user: user, plus: true)
    }
    
    func plusPressed(user: ConnectionRequest?) {
        delegate?.plusPressed(user: user)
    }
    
    func minusPressed(user: ConnectionRequest?) {
        delegate?.minusPressed(user: user)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension NewConnectionsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @objc func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
        if longPressGR.state == .ended {
            return
        }
        
        let point = longPressGR.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        
        if let indexPath = indexPath {
            //print("connections = \(connections)")
            if indexPath.row != 0 {
                //let connection = ambassadorships[indexPath.row - 1]
                //revokIndex = indexPath.row - 1
                //showRemoveDialog(connection: connection)
                
                let connection = ambassadorships[indexPath.row]
                revokIndex = indexPath.row - 1 //Sameer 12/5/2020 crash log
                showRemoveDialog(connection: connection)
                
            }
            print(indexPath.row)
        } else {
            print("Could not find index path")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if UIDevice.current.screenType == UIDevice.ScreenType.iPhones_5_5s_5c_SE { return 20 }
        return UIDevice.current.screenType == UIDevice.ScreenType.iPhones_6_6s_7_8 ? 10 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ambassadorships.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "brandCell", for: indexPath)
//        if (indexPath.row == 0) {
//            if let imageView = cell.contentView.subviews[0] as? UIImageView {
//                imageView.clipsToBounds = true
//                imageView.layer.masksToBounds = true
//                imageView.layer.cornerRadius = 30
//                imageView.layer.borderWidth = 2
//                imageView.layer.borderColor = UIColor.init(hexString: "4b23bd").cgColor
//
//                imageView.image = UIImage(named: "findbrands2")
//            }
//            return cell
//        }
        let item = ambassadorships[indexPath.row]
        if let imageView = cell.contentView.subviews[0] as? UIImageView {
            print("image view = \(cell.contentView.frame)")
            imageView.clipsToBounds = true
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 30
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = Color.newGray.cgColor//UIColor.init(hexString: "4b23bd").cgColor
            
            if let url = URL(string: item.brand.logotypeUrl) {
                imageView.af_setImage(withURL: url)
                imageView.backgroundColor = Color.backgroundColorFadedDark()
            } else {
                //imageView.image = UIImage(named: "defaultbrand")
                imageView.backgroundColor = Color.backgroundColorFadedDark()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if (indexPath.row == 0) {
//            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NearbyViewController") as! NearbyViewController
//            vc.delegate = self
//            navigationController?.pushViewController(vc, animated: true)
//        }
         if user!.isCurrentUser {
            let contentViewController = UIStoryboard(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "ContentController") as! ContentSetupViewController
            contentViewController.ambassadorship = ambassadorships[indexPath.row]
            contentViewController.user = user
            
            //delegate?.showMenu(true)
            
            //present(contentViewController, animated: true, completion: nil)
            show(contentViewController, sender: nil)
        }
    }
}

extension NewConnectionsViewController: BrandAddedProtocol {
    
    func brAdded(brand: Ambassadorship?) {
        if let brand = brand {
            if ambassadorships.contains(where: { (item) -> Bool in return item.id == brand.id }) {
                return
            }
            ambassadorships.append(brand)
            let rows = Double(ambassadorships.count + 1) / Double(3)
            print("rows = \(rows)")
            collectionViewHeightConstraint.constant = CGFloat(ceil(rows) * 85)
            collectionView?.reloadData()
        }
    }
}

extension NewConnectionsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //del2.connections =
        return true
    }
}


extension NewConnectionsViewController: UIScrollViewDelegate {
    
    //scroll
  
}

