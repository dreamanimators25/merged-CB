//
//  ConnectionsViewController.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 09/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import Crashlytics

class ConnectionsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ConnectionRequestTableViewCellDelegate, ConnectionsTableViewCellDelegate, AmbassadorshipsCollectionViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var tableView: TableView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    
    var connections: [Connection]?{
        didSet {
            //print("From user: \(String(describing: connections?[0].fromUser.id))")
            //print("To user: \(String(describing: connections?[0].toUser.id))")
            self.tableView.reloadData()
        }
    }
    
    // MARK: Data
    var ambassadorshipsCollectionViewController: AmbassadorshipsCollectionViewController?
    var user: User?
    private var deleteIsActive = false
    private var tap: UITapGestureRecognizer!
    private let currentUser = UserManager.sharedInstance.user
    
    var connectionRequests: [ConnectionRequest]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Managers
    var profileContentTransitionManager: ProfileContentTransitionManager?
    let imagePicker = UIImagePickerController()
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //closeButton.imageView?.contentMode = .scaleAspectFit
        tap = UITapGestureRecognizer(target: self, action: #selector(screenTapped(_:)))
        tap.isEnabled = false
        self.view.addGestureRecognizer(tap)
        
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.rightBarButtonItem = NavigationBar.closeButtonWithTarget(self, action: #selector(closeButtonTapped(_:)))
        navigationItem.rightBarButtonItem?.image = navigationItem.rightBarButtonItem?.image?.af_imageScaled(to: CGSize(width: 50, height: 50))
        navigationItem.rightBarButtonItem?.image = navigationItem.rightBarButtonItem?.image?.withRenderingMode(.alwaysOriginal)
        
        let searchIcon = UIImage(named: "search")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: searchIcon, style: .plain, target: self, action: #selector(showUserSearch))
        
        tableView.register(UINib(nibName: "ConnectionRequestTableViewCell", bundle: nil), forCellReuseIdentifier: ConnectionRequestTableViewCell.cellIdentifier)
        tableView.register(UINib(nibName: "ConnectionsTableViewCell", bundle: nil), forCellReuseIdentifier: ConnectionsTableViewCell.cellIdentifier)
        
        
    }
    
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func showUserSearch() {
        performSegue(withIdentifier: "showUserSearchSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUserInfo()
        
        
        updateConnections()
        updateConnectionRequests()
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
            //navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(settingsButtonTapped(_:)))
                    } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close_small"), style: .plain, target: self, action: #selector(closeButtonTapped(_:)))
            
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
        if user!.isCurrentUser {
            
            let contentViewController = UIStoryboard(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "ContentController") as! ContentSetupViewController
            contentViewController.ambassadorship = ambassadorship
            contentViewController.user = user
        
            let logotypeImageViewRect = cell.convert(cell.logotypeImageView.frame, to: self.view)
            let imageView = cell.logotypeImageView
            if let image = imageView.image {
                self.profileContentTransitionManager = ProfileContentTransitionManager(fromBrandImage: image, fromBrandImageViewFrameInViewController: logotypeImageViewRect)
                contentViewController.transitioningDelegate = self.profileContentTransitionManager
            }
        
            //present(contentViewController, animated: true, completion: nil)
            show(contentViewController, sender: nil)
            imageView.alpha = 0
            delay(1.0, closure: {
                imageView.alpha = 1
            })
        }
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
    
    
    // MARK: - Connections
    
    fileprivate func updateConnections() {
        guard user != nil else {
            print("User not found in ConnectionsTableViewController")
            return
        }
        UserManager.sharedInstance.getConnectionsForUser(user!, completion: { (connections, error) in
            if let connections = connections {
                self.connections = connections
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        })
        self.tableView.reloadData()
    }
    
    fileprivate func updateConnectionRequests() {
        guard user != nil else {
            print("User not found in ConnectionsTableViewController")
            return
        }
        UserManager.sharedInstance.getConnectionRequestForUser(user!, completion: { (connectionRequests, error) in
            if let connectionRequests = connectionRequests {
                self.connectionRequests = connectionRequests.filter({ !$0.requestRejected })
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        })
    }
    
    fileprivate func removeConnection(_ connection: Connection) {
        guard let user = UserManager.sharedInstance.user else {
            print("User not found in ConnectionsTableViewController")
            return
        }
        UserManager.sharedInstance.deleteConnectionForUser(user, connection: connection) { (connection, error) in
            self.updateConnections()
        }
    }
    
    // MARK: - Actions
    
    @objc func closeButtonTapped(_ id: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let connectionRequests = connectionRequests, section == 0 {
            return connectionRequests.count
        } else if let connections = connections, section == 1 {
            return connections.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return ConnectionRequestTableViewCell.cellHeight
        }
        return ConnectionsTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
            return 44.0
        }
        return 0.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let height = self.tableView(tableView, heightForHeaderInSection: section)
        let width = tableView.bounds.width
        let text = {
            return section == 0 ? NSLocalizedString("REQUESTS", comment: "") : NSLocalizedString("CONNECTIONS", comment: "")
        }()
        return TableViewStyler.headerViewWithWitdth(width, height: height, text: text)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let connectionRequests = connectionRequests, indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ConnectionRequestTableViewCell.cellIdentifier, for: indexPath) as! ConnectionRequestTableViewCell
            cell.delegate = self
            
            let connectionRequests = connectionRequests[indexPath.row]
            cell.updateWithConnectionRequest(connectionRequests)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ConnectionsTableViewCell.cellIdentifier, for: indexPath) as! ConnectionsTableViewCell
            cell.delegate = self
            if let connections = connections {
                let connection = connections[indexPath.row]
                cell.updateWithConnection(connection)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            if let connections = connections {
                let connection = connections[indexPath.row]
                navigateToUser(connection.toUser)
            }
        }
    }
    
    // MARK: - Accept/decline
    
    fileprivate func acceptConnectionRequest(_ connectionRequest: ConnectionRequest) {
        guard let user = UserManager.sharedInstance.user else {
            print("User not found in ConnectionRequestsViewController")
            return
        }
        UserManager.sharedInstance.updateConnectionRequestForUser(user, connectionRequest: connectionRequest, connectionRequestAction: ConnectionRequestAction.Accept) { (connectionRequest, error) in
            if let _ = connectionRequest {
                self.updateConnectionRequests()
                self.updateConnections()
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
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
                self.updateConnections()
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
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
                self.updateConnections()
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        }
    }
    
    // MARK: - ConnectionRequestTableViewCellDelegate
    
    func didTapAcceptButtonForConnectionRequestTableViewCell(_ cell: ConnectionRequestTableViewCell) {
        if let connectionRequests = connectionRequests, let indexPath = tableView.indexPath(for: cell) {
            let connectionRequest = connectionRequests[indexPath.row]
            acceptConnectionRequest(connectionRequest)
        }
    }
    
    func didTapDeclineButtonForConnectionRequestTableViewCell(_ cell: ConnectionRequestTableViewCell) {
        if let connectionRequests = connectionRequests, let indexPath = tableView.indexPath(for: cell) {
            let connectionRequest = connectionRequests[indexPath.row]
            declineConnectionRequest(connectionRequest)
        }
    }
    
    func didTapCancelButtonForConnectionRequestTableViewCell(_ cell: ConnectionRequestTableViewCell) {
        if let connectionRequests = connectionRequests, let indexPath = tableView.indexPath(for: cell) {
            let connectionRequest = connectionRequests[indexPath.row]
            cancelConnectionRequest(connectionRequest)
        }
    }
    
    // MARK: - ConnectionsTableViewCellDelegate
    
    func didTapDeleteButtonForCell(_ cell: ConnectionsTableViewCell) {
        guard let connections = connections, let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let connection = connections[indexPath.row]
        let message = String(format: NSLocalizedString("REMOVE_CONNECTION_MESSAGE", comment: ""), connection.user.fullName)
        let alertController = UIAlertController(title: NSLocalizedString("REMOVE_CONNECTION", comment: ""), message: message, preferredStyle: UIAlertController.Style.actionSheet)
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("REMOVE", comment: ""), style: UIAlertAction.Style.destructive, handler: { (alertAction: UIAlertAction) in
            self.removeConnection(connection)
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("CANCEL", comment: ""), style: UIAlertAction.Style.cancel, handler: { (alertAction: UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    fileprivate func navigateToUser(_ user: User) {
        if !user.isCurrentUser {
            if let profileViewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? NewProfileViewController {
                profileViewController.user = user
                let rootNavigationController = RootNavigationController(navigationBarClass: NavigationBar.self, toolbarClass: nil)
                rootNavigationController.viewControllers = [profileViewController]
                rootNavigationController.modalTransitionStyle = .crossDissolve
                present(rootNavigationController, animated: true, completion: nil)
            }
        }

    }

}
