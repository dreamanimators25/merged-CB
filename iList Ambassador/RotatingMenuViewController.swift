//
//  RotatingMenuViewController.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-07-23.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit
import Crashlytics
import Alamofire

protocol RotatingMenuViewControllerDelegate: class {
    func menuAction(segue: String)
    func showRewards()
    func selectedAmbassadorship(ambassadorShip: Ambassadorship)
    func showProfile()
    func showBrands()
    func showConnections()
}


protocol FavoriteViewDelegate: class {
    func didSelectShip(ship: Ambassadorship?)
}

class FavoriteView: HexagonalImageView {
    @IBOutlet private weak var imageView: UIImageView!
    
    weak var delegate: FavoriteViewDelegate?
    
    weak var ship: Ambassadorship? {
        didSet {
            guard let brand = ship?.brand, let url = URL(string: brand.logotypeUrl) else { return }
            imageView.af_setImage(withURL: url)
        }
    }
    
    @IBAction private func didClickFavoriteButton(_ sender: UIButton) {
        delegate?.didSelectShip(ship: ship)
    }
}

extension Array {
    func get(index: Int) -> Element? {
        guard index < Int(count), index >= 0 else { return nil }
        return self[index]
    }
}

extension RotatingMenuViewController: FavoriteViewDelegate {
    func didSelectShip(ship: Ambassadorship?) {
        guard let ship = ship else {
            //CHANGE: Add functionality for selecting favorites here
                delegate?.menuAction(segue: "presentConnectionsSegue")
            return
        }
        delegate?.selectedAmbassadorship(ambassadorShip: ship)
    }
}

extension RotatingMenuViewController: setProfilePicDelegate {
    func setProfilePictureForMenu(_ image: UIImage) {
        self.profilePicture.image = image
        print("IN SETPROFILEPICTURE")
    }
}



class RotatingMenuViewController: UIViewController {

    @IBOutlet private weak var menuContainer: UIView!
    @IBOutlet private weak var menuItemOne: UIView!
    @IBOutlet private weak var menuItemTwo: UIView!
    @IBOutlet private weak var menuItemThree: UIView!
    @IBOutlet private weak var menuItemFour: FavoriteView!
    @IBOutlet private weak var menuItemFive: FavoriteView!
    @IBOutlet private weak var menuItemSix: FavoriteView!
    @IBOutlet private weak var menuItemSeven: FavoriteView!
    
    @IBOutlet weak var profilePicture: HexagonalImageView!
    
    
    
    weak var delegate: RotatingMenuViewControllerDelegate?
    
    private var ships: [Ambassadorship]? {
        didSet {
            guard let ships = ships else { return }
            
            menuItemFour.ship = ships.get(index: 0)
            menuItemFive.ship = ships.get(index: 1)
            menuItemSix.ship = ships.get(index: 2)
            menuItemSeven.ship = ships.get(index: 3)
        }
    }

    private var hide = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuContainer.alpha = 0
        menuItemOne.alpha = 0
        menuItemTwo.alpha = 0
        menuItemThree.alpha = 0
        menuItemFour.alpha = 0
        menuItemFive.alpha = 0
        menuItemSix.alpha = 0
        menuItemSeven.alpha = 0
        
        
        
        menuItemFour.delegate = self
        menuItemFive.delegate = self
        menuItemSix.delegate = self
        menuItemSeven.delegate = self
        addSwipegestures()
        loadFavorites()
        revealMenu(menuContainer)
        
    }
    
    private func addSwipegestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    private func loadFavorites() {
        guard let id = UserManager.sharedInstance.user?.id else { return }
        // CHANGE: Ny request, .getfavorites which is implemented in BE and then process them essentially the same
        AmbassadorshipManager.sharedInstance.getAmbassadorshipsForUser(id, page: 1, pageSize: 20) { (ambassadorships, error) in
            if let ambassadorships = ambassadorships {
                self.processAmabassadorShips(ships: ambassadorships)
                
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        }
    }
    
    private func processAmabassadorShips(ships: [Ambassadorship]) {
        self.ships = ships
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            animate(menu: menuContainer, directionContainer: .pi, directionItems: -.pi)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            animate(menu: menuContainer, directionContainer: -.pi, directionItems: .pi)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            animate(menu: menuContainer, directionContainer: .pi, directionItems: -.pi)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
        animate(menu: menuContainer, directionContainer: -.pi, directionItems: .pi)
        }
    }

    func revealMenu(_ menu: UIView) {
        UIView.animateKeyframes(withDuration: 1,
                                delay: 1,
                                animations: {
                                    self.menuContainer.alpha = 1
                                    self.menuItemOne.alpha = 1
                                    self.menuItemTwo.alpha = 1
                                    self.menuItemThree.alpha = 1
                                    self.menuItemFour.alpha = 1
                                    self.menuItemFive.alpha = 1
                                    self.menuItemSix.alpha = 1
                                    self.menuItemSeven.alpha = 1
        },
                                completion: nil)
    }
    func animate(menu: UIView, directionContainer: CGFloat, directionItems: CGFloat) {
        UIView.animateKeyframes(withDuration: 0.3,
                                delay: 0,
                                animations: {
                                    self.menuContainer.transform = self.menuContainer.transform.rotated(by: directionContainer / 3)
                                    
                                    self.menuItemOne.transform = self.menuItemOne.transform.rotated(by: directionItems / 3)
                                    self.menuItemTwo.transform = self.menuItemTwo.transform.rotated(by: directionItems / 3)
                                    self.menuItemThree.transform = self.menuItemThree.transform.rotated(by: directionItems / 3)
                                    self.menuItemFour.transform = self.menuItemFour.transform.rotated(by: directionItems / 3)
                                    self.menuItemFive.transform = self.menuItemFive.transform.rotated(by: directionItems / 3)
                                    self.menuItemSix.transform = self.menuItemSix.transform.rotated(by: directionItems / 3)
                                    self.menuItemSeven.transform = self.menuItemSeven.transform.rotated(by: directionItems / 3)
        },
                                completion: nil)
    }
    
    
    
    
    @IBAction func hideMenuButtonTapped(_ sender: UIButton) {
        if self.hide == true {
            hideMenu(menuContainer)
            self.hide = false
        } else {
            showMenu(menuContainer)
            self.hide = true
        }
        
        
    }
    func showMenu(_ menu: UIView) {
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, animations: {
            self.menuItemOne.alpha = 1
            self.menuItemTwo.alpha = 1
            self.menuItemThree.alpha = 1
            self.menuItemFour.alpha = 1
            self.menuItemFive.alpha = 1
            self.menuItemSix.alpha = 1
            self.menuItemSeven.alpha = 1
        }, completion: nil)
    }
    func hideMenu(_ menu: UIView) {
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, animations: {
            self.menuItemOne.alpha = 0
            self.menuItemTwo.alpha = 0
            self.menuItemThree.alpha = 0
            self.menuItemFour.alpha = 0
            self.menuItemFive.alpha = 0
            self.menuItemSix.alpha = 0
            self.menuItemSeven.alpha = 0
        }, completion: nil)
    }
    
    
    @IBAction func activityButtonTapped(_ sender: AnyObject) {
        delegate?.menuAction(segue: "showActivitiesSegue")
        //performSegue(withIdentifier: "showActivitiesSegue", sender: sender)
    }
    
    @IBAction func ilistChannelButtonTapped(_ sender: UIButton) {
        delegate?.menuAction(segue: "contentSegue")
    }
    
    @IBAction func rewardsButtonsTapped(_ sender: UIButton) {
        delegate?.showRewards()
        delegate?.menuAction(segue: "rewardsSegue")
    }
    
    
    @IBAction func connectButtonTapped(_ sender: AnyObject) {
        if sender.tag == 4 {
            delegate?.showConnections()
            
           // delegate?.menuAction(segue: "presentConnectionsSegue")
        } else {
            delegate?.showBrands()
//            let brandConnectViewController = BrandConnectViewController()
//            // brandConnectViewController.delegate = ambassadorshipsCollectionViewController
//            present(brandConnectViewController, animated: true, completion: nil)
        }
      
 
    }
    
    @IBAction func showProfile(_ sender: UIButton) {
        delegate?.showProfile()
    }
    @IBAction func connectionsButtonTapped(_ sender: AnyObject) {
        //performSegue(withIdentifier: "presentConnectionsSegue", sender: sender)
    }
    
    
    
}
