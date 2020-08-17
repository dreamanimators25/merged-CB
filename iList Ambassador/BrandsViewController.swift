//
//  BrandsViewController.swift
//  iList Ambassador
//
//  Created by Dmitriy Zhyzhko on 24.02.2019.
//  Copyright © 2019 iList AB. All rights reserved.
//

import UIKit
import Foundation
import Crashlytics
import Firebase

final class BrandsViewController: UIViewController, BrandAddedProtocol {
    
    @IBOutlet weak var chinaBasinImageView: UIImageView!
    @IBOutlet weak var chinaBasinBrandView: UIView!
    @IBOutlet weak var promoView: PromoVideoView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate let user = UserManager.sharedInstance.user
    fileprivate var cellSize: CGFloat = 85
    fileprivate var ambassadorships: [Ambassadorship] = []
    
    weak var delegate: VisibilityDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.screenType == UIDevice.ScreenType.iPhones_6_6s_7_8 {
            cellSize = 78
        } else if UIDevice.current.screenType == UIDevice.ScreenType.iPhones_5_5s_5c_SE  {
            cellSize = 57
        } else  if UIDevice.current.screenType == UIDevice.ScreenType.iPhoneX {
            cellSize = 76
            //scrollView.contentInset = UIEdgeInsets(top:  10, left: 0, bottom: 0, right: 0)
        }
        self.makeBarButton()
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData(_:)),
                                               name: Notification.Name.init("reloadAmbasadro"), object: nil)
//        let promoURL = Bundle.main.url(forResource: "promo", withExtension: "mp4")
//        
//        promoView.videoURL = promoURL
    }
    
    
    
    func makeBarButton()
    {
          //self.makeClearNavigationBar()
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        let barButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.leftBarButtonItem = barButton
        
        
        let channelButton = UIButton.init(type: .custom)
        channelButton.setImage(UIImage(named: "add_brand_small")?.withRenderingMode(.alwaysOriginal), for: .normal)
        channelButton.addTarget(self, action: #selector(channelAddBtnTap(_:)), for: .touchUpInside)
        channelButton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        channelButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        let barButton2 = UIBarButtonItem(customView: channelButton)
        
        self.navigationItem.rightBarButtonItem = barButton2
    }
    
    @objc func closeButtonTapped(_ sender: AnyObject?) {
       self.onMenuPressed(sender)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.makeClearNavigationBar()
        getAmbassadorshipsForUser()

        promoView.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        promoView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let collectionContentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        collectionViewHeightConstraint.constant = collectionContentHeight
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func reloadData(_ sender: Any) {
        getAmbassadorshipsForUser()
    }
    
    @IBAction func chinaBasinTapped(_ sender: Any) {
        if user!.isCurrentUser {
            
            let contentViewController = UIStoryboard(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "ContentController") as! ContentSetupViewController
            contentViewController.ambassadorship = ambassadorships[0]
            contentViewController.user = user
            
            delegate?.showMenu(true)
            
            //present(contentViewController, animated: true, completion: nil)
            show(contentViewController, sender: nil)
        }
    }
    
    @IBAction func onMenuPressed(_ sender: Any) {
        if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsTableViewController") as? SettingsTableViewController {
            vc.user = user
            vc.isMenu = true
            
            let transition = CATransition()
            transition.duration = 0.4
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(vc, animated: true)
            //present(vc, animated: false, completion: nil)
        }
    }
    
    func brAdded(brand: Ambassadorship?) {
        if let brand = brand {
            if ambassadorships.contains(where: { (item) -> Bool in return item.id == brand.id }) {
                return
            }
            ambassadorships.append(brand)
            //let rows = Double(ambassadorships.count + 1) / Double(3)
            //print("rows = \(rows)")
            //collectionViewHeightConstraint.constant = CGFloat(ceil(rows) * 85)
            collectionView?.reloadData()
        }
    }
    
    @IBAction func onBrandPressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NearbyViewController") as! NearbyViewController
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onConnectionsPressed(_ sender: Any) {
        let brandConnectViewController = BrandConnectViewController()
        brandConnectViewController.delegate = self
        present(brandConnectViewController, animated: true, completion: nil)
    }
    
    //S
    @objc func channelAddBtnTap(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "", message: "Please Enter Referrel code!", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Referrel Code"
        }
        
        let saveAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { alert -> Void in
            //let firstTextField = alertController.textFields![0] as UITextField
            
            self.addChannel(Code: alertController.textFields![0].text ?? "")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //S
    private func addChannel(Code:String) {
        
        AmbassadorshipManager.sharedInstance.requestAmbassadorhipWithCode(Code) { (ambassadorship, error, code) in
            
            guard error == nil else {
                self.showAlertWithTitle(NSLocalizedString("Something went wrong.", comment: ""), message: nil, completion: {
                    
                })
                return
            }
            
            if let ambassadorship = ambassadorship {
                self.ambassadorships.append(ambassadorship)
                self.collectionView.reloadData()
                
                //self.delegate?.successfullySignForNewAmbassadorship(ambassadorship)
                //self.dismiss(animated: true, completion: nil)
                
            } else {
                self.showAlertWithTitle(NSLocalizedString("CONNECTION_CODE_DOES_NOT_EXISTS", comment: ""), message: nil, completion: {
                    
                })
            }
            
        }
    }
    
    private func getAmbassadorshipsForUser() {
        AmbassadorshipManager.sharedInstance.getAmbassadorshipsForUser(user!.id, page: 1, pageSize: 20) { [weak self] (ambassadorships, error) in
            
            guard let self = self else { return }
            
            if let ambassadorships = ambassadorships {
                
                self.ambassadorships = ambassadorships
                self.collectionView?.reloadDataForConstraints()
                self.chinaBasinBrandView.isHidden = ambassadorships.isEmpty
                
                guard !ambassadorships.isEmpty else { return }
                
                self.chinaBasinImageView.clipsToBounds = true
                self.chinaBasinImageView.layer.masksToBounds = true
                self.chinaBasinImageView.layer.cornerRadius = self.chinaBasinImageView.frame.height / 2
                self.chinaBasinImageView.layer.borderWidth = 2
                self.chinaBasinImageView.layer.borderColor = Color.newGray.cgColor
                
                if let url = URL(string: ambassadorships[0].brand.logotypeUrl) {
                    self.chinaBasinImageView.af_setImage(withURL: url)
                    self.chinaBasinImageView.backgroundColor = Color.backgroundColorFadedDark()
                } else {
                    self.chinaBasinImageView.image = UIImage(named: "defaultbrand")
                    self.chinaBasinImageView.backgroundColor = Color.backgroundColorFadedDark()
                }
                
                //Written by sameer on 6/3/20
                if isComeFromPush {
                    
                    if ambassadorships.contains(where: { $0.id == channelIdPush }) {
                        
                        if self.user!.isCurrentUser {
                            let contentViewController = UIStoryboard(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "ContentController") as! ContentSetupViewController
                            
                            if let ind = ambassadorships.index(where: { $0.id == channelIdPush }) {
                                contentViewController.ambassadorship = ambassadorships[ind]
                                contentViewController.user = self.user
                                self.delegate?.showMenu(true)
                                self.navigationController?.pushViewController(contentViewController, animated: true)
                            }
                            
                        }
                        
                    }
                    
                }
                
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        }
    }
}

// MARK: - BrandConnectDelegate
extension BrandsViewController: BrandConnectDelegate {
    func successfullySignForNewAmbassadorship(_ ambassador: Ambassadorship) {
        guard !ambassadorships.contains(where: { $0.id == ambassador.id }) else { return }
        ambassadorships.append(ambassador)
        collectionView?.reloadData()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension BrandsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if (section == 0)
        {
            return 0
        }
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (indexPath.section == 0)
        {
            return  CGSize(width: collectionView.frame.width, height: self.view.frame.height * 0.33)
        }
        let size = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right) - 24) / 2
        cellSize = size
        return CGSize(width: cellSize, height: cellSize + 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return ambassadorships.count - 1
        if (section == 0)
        {
            //return 1  Sameer on 10/4/20
            return 0
        }
        return ambassadorships.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (indexPath.section == 0)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCell", for: indexPath)

            return cell
        }
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "brandCell", for: indexPath)
//      let item = ambassadorships[indexPath.row + 1]
        let item = ambassadorships[indexPath.row]

        if let imageView = cell.contentView.subviews[0] as? UIImageView {
            print("image view = \(cell.contentView.frame)")
            imageView.clipsToBounds = true
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = CGFloat(cellSize / 2)
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = Color.newGray.cgColor
            
            
            if let url = URL(string: item.brand.logotypeUrl) {
                imageView.af_setImage(withURL: url)
                imageView.backgroundColor = Color.backgroundColorFadedDark()
            } else {
                //imageView.image = UIImage(named: "defaultbrand")
                imageView.backgroundColor = Color.backgroundColorFadedDark()
            }
            
        }
        
        let lbl = cell.viewWithTag(1) as! UILabel
        lbl.text = item.brand.name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.section == 0)
        {
            return
        }
        if user!.isCurrentUser {
            
            let contentViewController = UIStoryboard(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "ContentController") as! ContentSetupViewController
            //contentViewController.ambassadorship = ambassadorships[indexPath.row + 1]
            contentViewController.ambassadorship = ambassadorships[indexPath.row]
            contentViewController.user = user
            
            delegate?.showMenu(true)
            
            //present(contentViewController, animated: true, completion: nil)
            navigationController?.pushViewController(contentViewController, animated: true)
            //show(contentViewController, sender: nil)
        }
    }
}

