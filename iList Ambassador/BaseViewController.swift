//
//  BaseViewController.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 18/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.backgroundColorWhite()
    }

}

class BaseCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.backgroundColorWhite()
    }
    
}

class BaseTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.backgroundColorWhite()
    }
    
}