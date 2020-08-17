//
//  RewardsSetupViewController.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-07-24.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit
import Crashlytics
import Alamofire
import AlamofireImage


class RewardsSetupViewController: UICollectionViewController, UINavigationControllerDelegate {
  
    
    var influencerBadgeArray: [Bool]?
    var levelBadgeArray: [Bool]?
    var rewardsArray = [RewardList]()
    var badgeArray = [Badge]()
    
    var user: User?
    fileprivate var id: Int?
    fileprivate var rewardId: Int?
    fileprivate var iconImage: UIImage?
    fileprivate var currentUser: User?
    fileprivate var brand: Brand?
    fileprivate var fullReward: Reward?
    fileprivate var UserScore: Int?
    fileprivate var Level: [Bool]?
    fileprivate var overLayViewHeight: CGFloat = 16.0
    fileprivate let cellWidth: CGFloat = 60
    fileprivate let cellHeight: CGFloat = 60
    
    @IBOutlet weak var errorField: UILabel!
    @IBOutlet weak var rewardImage: HexagonalImageView!
    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        closeButtonTapped(sender as AnyObject)
    }
    
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    @IBAction func singleRewardButtonPressed(_ sender: UIButton) {
        
        let currentUser = UserManager.sharedInstance.user
        getSingleReward((currentUser?.id)!, rewardsArray[0].id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getScore((user?.id)!)
        setRewardsList((user?.id)!)
        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.tintColor = .clear
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func closeButtonTapped(_ id: AnyObject?) {
        dismiss(animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: true)
    }
    
    func setRewardsList(_ id: Int) {
        RewardManager.sharedInstance.getRewardsForId(id) { (rewards, error, success) in
            if success == true && (rewards?.count)! >= 0 {
                self.rewardsArray = rewards!
                for object in self.rewardsArray {
                    self.setRewardsListImg(object.iconUrl.absoluteString)
                }
                self.collectionView?.reloadData()
            }
        }
    }
    
    func setRewardsListImg(_ imgString: String) {
        Alamofire.request(imgString).responseImage { response in
            if let imageResult = response.result.value {
                self.iconImage = (imageResult)
            }
        }
    }
    
    private func getScore(_ id: Int) {
        RewardManager.sharedInstance.getUserScore(id) { (score, error, success ) in
            if success == true {
                    guard let score = score?["userScore"] as? Int else { return }
                    self.UserScore = score
            }
        }
    }
    
    
    
    fileprivate func getSingleReward(_ id: Int, _ rewardId: Int) {
        RewardManager.sharedInstance.getFullReward(id, rewardId: rewardId) { (rewards, error, success) in
            if success == true {
                self.fullReward = rewards?[0]
                print("Performing request for full reward has finished")
                DispatchQueue.main.async(execute: {
                    self.doTheSegue()
                })
            }
            else {
                print("Getting the full reward did not complete for some reason")
            }
        }
    }
    
    private func doTheSegue() {
        performSegue(withIdentifier: "singleRewardSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "singleRewardSegue" {
            let destination = segue.destination as! SingleRewardController
            print("Setting destination reward item")
            destination.singleRewardMetaData = self.fullReward
            print("Destination reward item has been set")
        }
    }
}


extension RewardsSetupViewController {
    
    fileprivate func rewardForSection(_ index: Int) -> RewardList {
        return rewardsArray[index]
    }
    
    fileprivate func badgeForSection(_ index: Int) -> Badge {
        return badgeArray[index]
    }
    
    func titleForSectionAtIndexPath(_ indexPath: IndexPath) -> String? {
        switch (indexPath as NSIndexPath).section {
        case 0:
            return ""
        case 1:
            return (self.UserScore != nil) ? String(describing: UserScore) : "0"
        case 2:
            return "Level"
        case 3:
            return "Influencer"
        case 4:
            return "Badges"
        case 5:
            return "Rewards"
            
        default:
            return ""
        }
    }
    
    private func itemsPerSection(_ indexPath: Int) -> Int {
        switch indexPath {
        case 0:
            return 0
        case 1:
            return 0
        case 2:
            return 4
        case 3:
            return 4
        case 4:
            return badgeArray.count
        case 5:
            return rewardsArray.count
        default: return 0
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsPerSection(section)
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath) as! EmptyCell
                return cell
            case 2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! LevelCell
                if let levelStatus = levelBadgeArray?[indexPath.row] {
                    cell.setImage = levelStatus
                }
                return cell
            case 3:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfluencerCell", for: indexPath) as! InfluencerCell
                if let InfluencerStatus = influencerBadgeArray?[indexPath.row] {
                    cell.setImage = InfluencerStatus
                }
                return cell
            case 4:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BadgeCell", for: indexPath) as! BadgeCell
                let badge = badgeForSection(indexPath.row)
                cell.badge = badge
                return cell
            case 5:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RewardCell", for: indexPath) as! RewardCell
                
                let singleReward = rewardForSection(indexPath.row)
                cell.cellReward = singleReward
                
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath) as! EmptyCell
                return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let HeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
        if let title = titleForSectionAtIndexPath(indexPath) {
            HeaderView.title = title
            
            switch indexPath.section {
            case 0:
                //HeaderView.line.isHidden = true
                HeaderView.closeButton.isHidden = true
            case 1:
                //HeaderView.line.isHidden = true
                HeaderView.closeButton.imageView?.contentMode = .scaleAspectFit
                HeaderView.closeButton.isHidden = false
            default: break
                
            }
           
        }
        return HeaderView
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentUser = UserManager.sharedInstance.user
        if indexPath.section == 5 {
            getSingleReward((currentUser?.id)!, rewardsArray[indexPath.item].id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        let edgeInset = ((SCREENSIZE.width) - (5 * cellWidth)) / 2
        return UIEdgeInsetsMake(0, edgeInset, 0, edgeInset)
    }
    
    
    
}
