//
//  OutboundShareManager.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 2017-02-26.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit

class OutboundShareManager {
    
    var presentingViewController: UIViewController
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    func shareOutbound(withContentId contentId: Int) {
        ContentManager.sharedInstance.createOutboundLink(contentId) { [weak self] (response: [String : Any]?, error: Error?) in
            if let response = response, let identifier = response["identifier"] as? String {
                let link = "http://backoffice.ilistambassador.com/share/" + identifier
                self?.shareLink(link)
            } else {
                self?.showShareErrorMessage()
            }
        }
    }
    
    private func shareLink(_ link: String) {
        if let linkUrl = URL(string: link) {
            let objectsToShare = [linkUrl, link] as [Any]
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact]
            presentingViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func showShareErrorMessage() {
        presentingViewController.showErrorAlert(withMessage: NSLocalizedString("UNABLE_TO_SHARE_CONTENT", comment: ""))
    }
}
