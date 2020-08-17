//
//  SendContentViewController.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 02/05/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class SendContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var contents: [Content]?
    
    // MARK: Views
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateContent()
    }
    
    // MARK: - Content
    
    func updateContent() {
//        ContentManager.sharedInstance
        
        // TODO: 
//        ?is_sharable to the ambassadorship_content API

    }
    
    
    // MARK: - UITableViewDelegate/UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let contents = contents {
            return contents.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        cell.textLabel?.font = Font.normalFont(FontSize.Large)
        cell.textLabel?.textColor = Color.darkGrayColor()
        TableViewStyler.removeSeparatorInsetsForCell(cell)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ActivitiesTableViewCell", forIndexPath: indexPath)
        if let contents = contents {
            let content = contents[indexPath.row]
            cell.textLabel?.text = content.title
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

    
}
