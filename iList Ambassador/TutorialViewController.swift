//
//  TutorialViewController.swift
//  iList Ambassador
//
//  Created by Dmitriy Zhyzhko on 14.09.2018.
//  Copyright © 2018 iList AB. All rights reserved.
//

import UIKit

class TutorialViewController: UIPageViewController, ClickNavigation {
    
    var type = 1
    var isAnimFinished = true
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newPageViewController(1),
                self.newPageViewController(2),
                self.newPageViewController(3)]
    }()
    
    private func newPageViewController(_ type: Int) -> UIViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
        vc.type = type
        vc.delegate = self
        return vc
    }
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    func action() {
        self.handleSuccessfullyAuthenticatedWithUser()
    }
    
    func click(back: Bool) {
//        if !isAnimFinished { return }
//
//        isAnimFinished = false
//
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//             self.isAnimFinished = true
//        }

        
        type = back ? type - 1 : type + 1
        print("type = \(type)")
        setViewControllers([orderedViewControllers[type - 1]],
                           direction: back ? .reverse : .forward,
                           animated: true,
                           completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: UIPageViewControllerDataSource

extension TutorialViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (!completed) {
            return
        }
        
        guard let viewControllerIndex = orderedViewControllers.index(of: pageViewController.viewControllers!.first!) else
        { return }
        
        type = viewControllerIndex + 1
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        print("next")
        return orderedViewControllers[nextIndex]
    }
    

    
}
