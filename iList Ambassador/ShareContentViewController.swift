//
//  ShareContentViewController.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-08-11.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import Crashlytics

class ShareContentViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var contentShareId = 0
    var connections: [Connection]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var performOutboutShareOnAppear: Bool = false
    
    lazy var outboundShareManager: OutboundShareManager = {
        return OutboundShareManager(presentingViewController: self)
    }()
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("SHARE", comment: "")
        navigationItem.leftBarButtonItem = NavigationBar.closeButtonWithTarget(self, action: #selector(closeButtonTapped(_:)))
        
        if let storedConnections = UserManager.sharedInstance.connections {
            connections = storedConnections
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateConnections()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if performOutboutShareOnAppear {
            performOutboutShareOnAppear = false
            outboundShareManager.shareOutbound(withContentId: contentShareId)
        }
    }
    
    // MARK: - Connections
    
    fileprivate func updateConnections() {
        guard let user = UserManager.sharedInstance.user else {
            print("User not found in ConnectionsTableViewController")
            return
        }
        UserManager.sharedInstance.getConnectionsForUser(user, completion: { [weak self] (connections, error) in
            if let connections = connections {
                self?.connections = connections
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        })
    }
    
    // MARK: - Actions
    
    @objc func closeButtonTapped(_ id: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Share
    
    func shareInsideApp(forCell cell: ShareUserTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell), let connections = connections else {
            return
        }
        
        let connection = connections[indexPath.row]
        
        let shareButton = cell.shareButton
        shareButton?.startLoading()
        
        let contentId = self.contentShareId
        let userId = connection.user.id
        
        ContentManager.sharedInstance.shareContent(contentId, targetUserId: userId, completion: { [weak self] success, error in
            shareButton?.stopLoading()
            if success {
                DispatchQueue.main.async(execute: {
                    shareButton?.setTitle(NSLocalizedString("SHARED", comment: ""), for: UIControl.State())
                    shareButton?.isEnabled = false
                })
            } else {
                DispatchQueue.main.async(execute: {
                    shareButton?.setTitle(NSLocalizedString("SHARE", comment: ""), for: UIControl.State())
                    shareButton?.isEnabled = true
                    self?.showShareErrorMessage()
                })
            }
        })
    }
    
    private func showShareErrorMessage() {
        showErrorAlert(withMessage: NSLocalizedString("UNABLE_TO_SHARE_CONTENT", comment: ""))
    }
    
}

extension ShareContentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let connections = connections {
            return connections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ConnectionsTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShareUserCell", for: indexPath) as! ShareUserTableViewCell
            if let connections = connections {
                let connection = connections[indexPath.row]
                cell.file = connection.user.profileImage
                cell.name = connection.user.fullName
                cell.userId = connection.user.id
                cell.contentId = contentShareId
                
                cell.onShareBlock = { [weak self] (cell: ShareUserTableViewCell) in
                    self?.shareInsideApp(forCell: cell)
                }
            }
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0 // 60
    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60.0))
//        view.backgroundColor = .clear
//        
//        let button = Button(frame: view.bounds.insetBy(dx: 16.0, dy: 8.0).offsetBy(dx: 0.0, dy: -8.0))
//        button.setTitle(NSLocalizedString("SHARE_LINK", comment: ""), for: .normal)
//        button.addTarget(self, action: #selector(shareOutsideApp), for: .touchUpInside)
//        view.addSubview(button)
//        
//        return view
//    }
    
}
