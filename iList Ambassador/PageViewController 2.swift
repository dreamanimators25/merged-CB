//
//  PageViewController.swift
//  iList Ambassador
//
//  Created by Dmitriy Zhyzhko on 14.09.2018.
//  Copyright © 2018 iList AB. All rights reserved.
//

import UIKit

protocol ClickNavigation {
    func click(back: Bool)
    func action()
}

class PageViewController: UIViewController {
    var type = 1
    
    @IBOutlet weak var imageVIew: UIImageView!
    @IBOutlet weak var actionView: UIView!
    
    @IBOutlet weak var prevImageView: UIImageView!
    @IBOutlet weak var nextImageView: UIImageView!
    
    var delegate: ClickNavigation?
    
    static var wasLast = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageVIew.image = UIImage.init(named: "tut-\(type)")
        
        print("type = \(type)")

        
        if !PageViewController.wasLast && type == 3 {
            PageViewController.wasLast = true
        }
        
        prevImageView.isHidden = type == 1
        nextImageView.isHidden = type == 3
        
        let nextTap = UITapGestureRecognizer(target: self, action: #selector(nextClick))
        nextImageView.isUserInteractionEnabled = true
        nextImageView.addGestureRecognizer(nextTap)
        
        let prevTap = UITapGestureRecognizer(target: self, action: #selector(prevClick))
        prevImageView.isUserInteractionEnabled = true
        prevImageView.addGestureRecognizer(prevTap)
        
        let actionTap = UITapGestureRecognizer(target: self, action: #selector(actionClick))
        actionView.isUserInteractionEnabled = true
        actionView.addGestureRecognizer(actionTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (actionView.subviews[1] as! UILabel).text = PageViewController.wasLast ? "Done" : "Skip"
    }
    
    @objc func actionClick() {
        delegate?.action()
    }
    
    @objc func nextClick() {
        delegate?.click(back: false)
    }
    
    @objc func prevClick() {
        delegate?.click(back: true)
    }
}
