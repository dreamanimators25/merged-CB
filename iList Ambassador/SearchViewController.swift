//
//  SearchViewController.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 19/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import Crashlytics

class SearchViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var users: [User]?
    
    // Views
    @IBOutlet weak var x: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIButton!
    
    var delegateAll: SimpleDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeBarButton()
        view.backgroundColor = .white
        closeButton.imageView?.contentMode = .scaleAspectFit
        //navigationItem.title = NSLocalizedString("CONNECTIONS", comment: "")
        
        x.delegate = self
        x.addTarget(self, action: #selector(searchTextFieldDidChange(_:)), for: .editingChanged)
        
        
        //searchTextField.delegate = self
        //searchTextField.editingDidChangeBlock = searchTextFieldDidChange
//        if let navigationBar = navigationController?.navigationBar {
//            searchTextField.frame = searchViewHolder.bounds
//            searchTextField.frame.size.height = 64.0
//        }
        
        //searchViewHolder = searchTextField
        //navigationItem.titleView = searchTextField
        tableView.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        
        tableView.register(UINib(nibName: UserTableViewCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: UserTableViewCell.cellIdentifier)
        tableView.tableFooterView = UIView()
        
        /*
        emptyStateLabel.font = Font.boldFont(16.0)
        emptyStateLabel.textColor = Color.ilistBackgroundColor()
        emptyStateButton.setTitle(NSLocalizedString("INVITE_A_FRIEND", comment: ""), for: UIControlState())
        
        checkEmptyState()
         */
        x.backgroundColor = .white
        x.textColor = UIColor.init(hexString: "4B23BD")
        tableView.backgroundColor = .clear
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
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        x.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegateAll?.updateAll()
    }
    
    // MARK: - Connections
    
    fileprivate func searchUserWithQuery(_ query: String) {
        searchActivityIndicatorView.startAnimating()
        UserManager.sharedInstance.searchUsersWithQuery(query, page: 1, pageSize: 20, completion: { (users, error) in
            self.searchActivityIndicatorView.stopAnimating()
            if let users = users {
                self.users = users
                self.tableView.reloadData()
                self.checkEmptyState()
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        })
    }
    
    // MARK: - Actions
    
    
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func emptyStateButtonTapped(_ sender: AnyObject) {
        let shareLinkString = NSLocalizedString("ILIST_SHARE_LINK", comment: "")
        if let linkUrl = URL(string: shareLinkString) {
            let objectsToShare = [linkUrl, shareLinkString] as [Any]
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact]
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func navigateToUser(_ user: User) {
        if let profileViewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? NewProfileViewController {
            profileViewController.user = user
            let rootNavigationController = RootNavigationController(navigationBarClass: NavigationBar.self, toolbarClass: nil)
            rootNavigationController.viewControllers = [profileViewController]
            rootNavigationController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            present(rootNavigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Empty state
    
    func checkEmptyState() {
//        if let users = users {
//            emptyStateLabel.text = NSLocalizedString("EMPTY_SEARCH_INFO", comment: "")
//            emptyStateView.isHidden = users.count > 0
//        } else {
//            emptyStateLabel.text = NSLocalizedString("EMPTY_SEARCH_INFO_NO_SEARCH", comment: "")
//            emptyStateView.isHidden = false
//        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let users = users {
            return users.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableViewStyler.defaultUserCellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        TableViewStyler.removeSeparatorInsetsForCell(cell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.cellIdentifier, for: indexPath) as! UserTableViewCell
        if let users = users {
            let user = users[indexPath.row]
            cell.nameLabel.text = user.fullName

            if let profilePictureString = user.profileImage, let profilePictureUrl = URL(string: profilePictureString) {
                cell.profilePictureImageView.af_setImage(withURL: profilePictureUrl)
            } else {
                cell.profilePictureImageView.af_cancelImageRequest()
                cell.profilePictureImageView.image = user.defaultImage()
                cell.profilePictureImageView.backgroundColor = Color.backgroundColorFadedDark()
            }
        }
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let users = users {
            let user = users[indexPath.row]
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
            //navigateToUser(user)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    @objc func searchTextFieldDidChange(_ textField: UITextField) {
        users = []
        tableView.reloadData()
        if let query = textField.text, query.count > 2 {
            searchUserWithQuery(query)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        x.resignFirstResponder()
        return true
    }

}
