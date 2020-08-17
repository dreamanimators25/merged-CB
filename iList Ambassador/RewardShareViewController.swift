//
//  RewardShareViewController.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-08-18.
//  Copyright © 2017 iList AB. All rights reserved.
//


import UIKit
import Crashlytics



class RewardShareViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ConnectionRequestTableViewCellDelegate, ConnectionsTableViewCellDelegate {
    
    
    @IBOutlet weak var tableView: TableView!
    
    @IBOutlet weak var closeButton: UIButton!
    var connections: [Connection]?{
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var connectionRequests: [ConnectionRequest]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.title = NSLocalizedString("KEEP_IN_TOUCH", comment: "")
        navigationItem.leftBarButtonItem = NavigationBar.closeButtonWithTarget(self, action: #selector(closeButtonTapped(_:)))
        
        let searchIcon = UIImage(named: "search-icon")?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: searchIcon, style: .plain, target: self, action: #selector(showUserSearch))
        
        tableView.register(UINib(nibName: "ConnectionRequestTableViewCell", bundle: nil), forCellReuseIdentifier: ConnectionRequestTableViewCell.cellIdentifier)
        tableView.register(UINib(nibName: "ConnectionsTableViewCell", bundle: nil), forCellReuseIdentifier: ConnectionsTableViewCell.cellIdentifier)
        
        if let storedConnections = UserManager.sharedInstance.connections {
            connections = storedConnections
        }
    }
    
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func showUserSearch() {
        performSegue(withIdentifier: "showUserSearchSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateConnections()
        updateConnectionRequests()
    }
    
    // MARK: - Connections
    
    fileprivate func updateConnections() {
        guard let user = UserManager.sharedInstance.user else {
            print("User not found in ConnectionsTableViewController")
            return
        }
        UserManager.sharedInstance.getConnectionsForUser(user, completion: { (connections, error) in
            if let connections = connections {
                self.connections = connections
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        })
    }
    
    fileprivate func updateConnectionRequests() {
        guard let user = UserManager.sharedInstance.user else {
            print("User not found in ConnectionsTableViewController")
            return
        }
        UserManager.sharedInstance.getConnectionRequestForUser(user, completion: { (connectionRequests, error) in
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
                shareWithUser(connection.user)
                
                dismiss(animated: true, completion: nil)
                
            }
        }
    }
    
    func shareWithUser(_ user: User) {
        
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
        if let profileViewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            profileViewController.user = user
            let rootNavigationController = RootNavigationController(navigationBarClass: NavigationBar.self, toolbarClass: nil)
            rootNavigationController.viewControllers = [profileViewController]
            rootNavigationController.modalTransitionStyle = .crossDissolve
            present(rootNavigationController, animated: true, completion: nil)
        }
        
    }
    
}
