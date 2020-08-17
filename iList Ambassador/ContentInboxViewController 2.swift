//
//  ContentInboxViewController.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 27/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class ContentInboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Views
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noContentLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    // MARK: Data
    var user: User?
    var ambassadorship: Ambassadorship?
    var inbox: [Content]? {
        didSet {
            if let activities = inbox {
                noContentLabel.isHidden = activities.count > 0
                tableView.reloadData()
            } else {
                noContentLabel.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        closeButton.imageView?.contentMode = .scaleAspectFit
        navigationItem.title = NSLocalizedString("INBOX", comment: "")
        noContentLabel.font = Font.normalFont(16.0)
        noContentLabel.textColor = Color.ilistBackgroundColor()
        noContentLabel.text = NSLocalizedString("NO_INBOX_YET", comment: "")
        tableView.register(UINib(nibName: "ContentTableViewCell", bundle: nil), forCellReuseIdentifier: ContentTableViewCell.cellIdentifier)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUsersReceivedContent((user?.id)!)
    }
    
    fileprivate func updateUsersReceivedContent(_ id: Int) {
        ContentManager.sharedInstance.getSharedContent(id, completion: {contents, error in
            if let contents = contents {
                self.inbox = contents
                
                
                /*print("INBOX LOADED!")
                let singleInboxElement = contents[0]
                let contentViewController = UIStoryboard(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "ContentController") as! ContentSetupViewController
                contentViewController.useContent = 1
                contentViewController.content = singleInboxElement
                if let imgString = singleInboxElement.pages[0].backgrounds?.file_url {
                    contentViewController.setBrandImg(imgString)
                }
                self.present(contentViewController, animated: true, completion: nil)
                */
             
            }
        })
    }
        
        
        /*
        ContentManager.sharedInstance.getInbox({inbox, error in
            guard inbox != nil else {
                return
            }
            self.inbox = inbox
        })
 
    }
 */
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func dismissViewController(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITableViewDelegate/UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let inbox = inbox {
            return inbox.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableViewStyler.defaultUserCellHeight * 2.5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContentTableViewCell.cellIdentifier, for: indexPath) as! ContentTableViewCell
        if let inbox = inbox {
            let inbox = inbox[indexPath.row]
            cell.updateWithContent(inbox)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let inbox = inbox {
            let singleInboxElement = inbox[indexPath.row]
        
            guard singleInboxElement != nil else { return }
            let id = singleInboxElement.id
            let contentViewController = UIStoryboard(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "ContentController") as! ContentSetupViewController
            contentViewController.useContent = 1
            contentViewController.content = singleInboxElement
            
            /*
            for item in singleInboxElement.pages[0].backgrounds ?? [] {
                if item.order == 0 {
                    contentViewController.setBrandImg(item.file_url ?? "")
                }
            }*/
            
            if let imgString = singleInboxElement.pages[0].backgrounds?.file_url {
                contentViewController.setBrandImg(imgString)
            }
            
            present(contentViewController, animated: true, completion: nil)
            
        }
    }
    
}
