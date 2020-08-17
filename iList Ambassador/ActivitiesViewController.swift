//
//  ActivitiesViewController.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 02/05/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import Crashlytics

class ActivitiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var activities: DataLoadState<[Activity]> = .loading {
        didSet {
            if case .loaded(let activities) = activities {
                emptyStateLabel.text = NSLocalizedString("NO_ACTIVITIES_YET", comment: "")
                emptyStateLabel.isHidden = !activities.isEmpty
            } else {
                emptyStateLabel.isHidden = true
            }
            self.tableView.reloadData()
        }
    }
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        return dateFormatter
    }()
    
    // Views
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("ACTIVITIES", comment: "")
        
        navigationItem.leftBarButtonItem = NavigationBar.closeButtonWithTarget(self, action: #selector(closeButtonTapped(_:)))
        
        emptyStateLabel.font = Font.normalFont(16.0)
        emptyStateLabel.textColor = Color.whiteColor()
        emptyStateLabel.text = NSLocalizedString("LOADING", comment: "") + "..."
        
        tableView.register(ActivitiesTableViewCell.self, forCellReuseIdentifier: ActivitiesTableViewCell.cellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateActivities()
    }
    
    fileprivate func updateActivities() {
        guard let currentUser = UserManager.sharedInstance.user else {
            return
        }
        ActivitiesManager.sharedInstance.getActivitiesForUser(currentUser) { (activities, error) in
            if let activities = activities {
                self.activities = .loaded(activities)
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        }
    }

    // MARK: - Actions
    
    @objc func closeButtonTapped(_ id: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
    
    func didSelectActivity(_ activity: Activity) {
        guard let type = activity.type else { return }
        switch type {
        case .user:
            if let userId = activity.actorId {
                self.goToUser(withId: userId)
            }
        }
    }
    
    fileprivate func goToUser(withId id: Int) {
        UserManager.sharedInstance.getUserWithId(id) { [weak self] (user: User?, error: Error?) in
            if let user = user {
                self?.goToUser(user)
            } else if let error = error {
                self?.showErrorAlert(withMessage: error.localizedDescription)
            }
        }
    }
    
    fileprivate func goToUser(_ user: User) {
        if let profileViewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            profileViewController.user = user
            let rootNavigationController = RootNavigationController(navigationBarClass: NavigationBar.self, toolbarClass: nil)
            rootNavigationController.viewControllers = [profileViewController]
            rootNavigationController.modalTransitionStyle = .crossDissolve
            present(rootNavigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UITableViewDelegate/UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if case .loaded(let activities) = activities {
            return activities.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        cell.textLabel?.font = Font.normalFont(FontSize.Large)
        cell.textLabel?.textColor = Color.darkGrayColor()
        TableViewStyler.removeSeparatorInsetsForCell(cell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActivitiesTableViewCell.cellIdentifier, for: indexPath) as! ActivitiesTableViewCell
        if case .loaded(let activities) = activities {
            let activity = activities[indexPath.row]
            cell.titleLabel.text = activity.actor
            cell.subtitleLabel.text = activity.verb
            if let timestamp = activity.timestamp {
                cell.dateLabel.text = dateFormatter.string(from: timestamp)
            } else {
                cell.dateLabel.text = "bajs"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if case .loaded(let activities) = activities {
            let activity = activities[indexPath.row]
            didSelectActivity(activity)
        }
    }
    
}
