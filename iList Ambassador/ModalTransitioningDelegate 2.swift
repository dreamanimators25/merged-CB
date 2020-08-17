//
//  ModalTransitioningDelegate.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 09/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class ModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate  {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let controller = ModalAnimatedTransitioning()
        controller.isPresenting = true
        return controller
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let controller = ModalAnimatedTransitioning()
        controller.isPresenting = false
        return controller
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
}

class ModalAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresenting: Bool = false
    
    var backgroundAlpha = CGFloat(0.6)
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let destinationViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! UIViewControllerContextTransitioning
        presentModalTransition(destinationViewController)
    }
    
    func presentModalTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let inView = transitionContext.containerView
        let modalViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        
        inView.addSubview(modalViewController.view)
        
        modalViewController.view.frame = CGRect(x: 0, y: SCREENSIZE.height, width: fromViewController.view.frame.width, height: fromViewController.view.frame.height)
        
        let oldBackgroundColor = modalViewController.view.backgroundColor
        
        let animatedBackgroundView = UIView(frame: inView.frame)
        animatedBackgroundView.backgroundColor = oldBackgroundColor
        
        inView.insertSubview(animatedBackgroundView, belowSubview: modalViewController.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            
            animatedBackgroundView.backgroundColor = UIColor(white: 0.0, alpha: self.backgroundAlpha)
            modalViewController.view.frame = fromViewController.view.bounds
            
        }, completion: { (finished: Bool) in
            animatedBackgroundView.removeFromSuperview()
            modalViewController.view.backgroundColor = UIColor(white: 0.0, alpha: self.backgroundAlpha)
            transitionContext.completeTransition(true)
        }) 
    }
    
    func dismissModalTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let inView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let modalViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        
        inView.addSubview(modalViewController.view)
        
        let oldBackgroundColor = modalViewController.view.backgroundColor
        
        let animatedBackgroundView = UIView(frame: inView.frame)
        animatedBackgroundView.backgroundColor = oldBackgroundColor
        
        inView.insertSubview(animatedBackgroundView, belowSubview: modalViewController.view)
        
        modalViewController.view.backgroundColor = UIColor.clear
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            animatedBackgroundView.backgroundColor = UIColor.clear
            modalViewController.view.frame = CGRect(x: 0, y: toViewController.view.frame.height, width: toViewController.view.frame.width, height: toViewController.view.frame.height)
        }, completion: { (finished: Bool) in
            animatedBackgroundView.removeFromSuperview()
            transitionContext.completeTransition(true)
            self.notifyControllerDidAppear(toViewController)
        }) 
        
    }
    
    func notifyControllerDidAppear(_ controller: AnyObject) {
        if let viewController = controller as? UIViewController {
            notifyViewControllerDidAppear(viewController)
        } else if let navigationController = controller as? UINavigationController, let viewController = navigationController.viewControllers.last {
            notifyViewControllerDidAppear(viewController)
        }
    }
    
    func notifyViewControllerDidAppear(_ viewController: UIViewController) {
        viewController.beginAppearanceTransition(true, animated: true)
        viewController.endAppearanceTransition()
    }
}

