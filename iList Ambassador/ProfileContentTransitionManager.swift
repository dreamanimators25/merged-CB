//
//  ProfileContentTransitionManager.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 28/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class ProfileContentTransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    var isPresenting: Bool = true
    
    var fromBrandImageView: ProfilePictureImageView?
    var fromBrandImageViewFrameInViewController: CGRect = CGRect.zero
    
    convenience init(fromBrandImage: UIImage, fromBrandImageViewFrameInViewController: CGRect) {
        self.init()

        self.fromBrandImageView = ProfilePictureImageView(frame: fromBrandImageViewFrameInViewController)
        self.fromBrandImageView!.image = fromBrandImage
        self.fromBrandImageViewFrameInViewController = fromBrandImageViewFrameInViewController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if isPresenting {
            return 0.5
        }
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            
        }
        let containerView = transitionContext.containerView
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from),
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
                return
        }
        
        var toBrandButton: UIButton?
        var fromViewBrandAnimationView: UIView?
        
        if let contentViewController = toViewController as? ContentSetupViewController {
            toBrandButton = contentViewController.brandButton
        }
        
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        
        toView.frame = fromView.frame
        toView.alpha = 0.0
        fromView.alpha = 1.0
        containerView.backgroundColor = UIColor.clear
        fromView.backgroundColor = UIColor.clear
        
        if let fromBrandImageView = fromBrandImageView {
            fromViewBrandAnimationView = fromBrandImageView.snapshotView(afterScreenUpdates: true)
            fromViewBrandAnimationView!.frame = fromBrandImageViewFrameInViewController
            containerView.addSubview(fromViewBrandAnimationView!)
        }
        fromBrandImageView?.backgroundColor = UIColor.clear
        containerView.backgroundColor = UIColor.clear
        fromView.backgroundColor = UIColor.clear
        
        fromBrandImageView?.isHidden = true
        toBrandButton?.isHidden = true
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: UIView.AnimationOptions(), animations: {
            
            fromView.alpha = 1.0
            toView.alpha = 1.0
            if let toBrandButton = toBrandButton, let fromViewBrandAnimationView = fromViewBrandAnimationView {
                fromViewBrandAnimationView.frame = toBrandButton.frame
            }
            
        }) { (finished: Bool) in
            self.fromBrandImageView?.isHidden = false
            toBrandButton?.isHidden = false
            toBrandButton?.setImage(self.fromBrandImageView?.image, for: UIControl.State())
            self.fromBrandImageView?.removeFromSuperview()
            fromViewBrandAnimationView?.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return nil
    }
    
}
