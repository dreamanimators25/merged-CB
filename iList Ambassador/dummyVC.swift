//
//  dummyVC.swift
//  iList Ambassador
//
//  Created by sameer khan on 10/09/20.
//  Copyright © 2020 iList AB. All rights reserved.
//

import UIKit

class dummyVC: UIViewController {
    
    @IBOutlet weak var height: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.height.constant = self.view.bounds.height
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }


}
