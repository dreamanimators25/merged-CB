//
//  WebViewController.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-06-13.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import SVWebViewController

class WebViewController: SVModalWebViewController {
 
    var contentId: Int?
    var link: String?
    
    convenience init(link: String, contentId: Int) {
        self.init(address: link)
        self.link = link
        self.contentId = contentId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        barsTintColor = Color.blueColor()
        NavigationBar.styleNavigationBar(navigationBar)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addObservers()
        sendDidAppearStatistics()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sendDidDisppearStatistics()
        removeObservers()
    }
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - Observers
    
    fileprivate func addObservers() {
        //NotificationCenter.default.addObserver(self, selector: #selector(WebViewController.sendDidAppearStatistics), name: UIApplication.willResignActiveNotification, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(WebViewController.sendDidAppearStatistics), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WebViewController.sendDidDisppearStatistics), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    // MARK: - Statistics
    
    @objc func sendDidAppearStatistics() {
        guard let _ = UserManager.sharedInstance.user,
            let _ = contentId,
            let _ = link else {
            debugPrint("WebViewController: no user/ambassadorshipContentId/link")
            return
        }
        // TODO: Send statistics to server.
        // print("sendDidAppearStatistics userId = \(user.id), ambassadorshipContentId = \( ambassadorshipContentId ), link: \( link )")
    }
    
    @objc func sendDidDisppearStatistics() {
        guard let _ = UserManager.sharedInstance.user,
            let _ = contentId,
            let _ = link else {
            debugPrint("WebViewController: no user/ambassadorshipContentId/link")
            return
        }
        // TODO: Send statistics to server.
        // print("sendDidDisppearStatistics userId = \(user.id), ambassadorshipContentId = \( ambassadorshipContentId ), link: \( link )")
    }
    
}
