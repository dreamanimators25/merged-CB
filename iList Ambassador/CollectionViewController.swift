//
//  CollectionViewController.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-07-31.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit
import Alamofire


private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {

    var rewardsArray: [Rewards]? {
        didSet {
            //Collectionview.reloadData()
        }
    }
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentUser = UserManager.sharedInstance.user
        getRewards((currentUser?.id)!)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 3
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCell", for: indexPath)
    
        // Configure the cell
    
        return cell
    }
    
    func getRewards(_ id: Int) {
        ContentManager.sharedInstance.getRewardsForId(id) { (rewards, error) in
            if (rewards?.count)! > 0 {
                self.rewardsArray = rewards!
            } else {
                print("Fitta")
                //self.errorField.text = "No rewards available"
            }
            
            // TODO: Remove once rewards are done
            for object in self.rewardsArray! {
                let id = object.id
                let title = object.title
                let url = object.iconURL
                print(id!)
                print(title!)
                print(url!)
            }
            
            //This code crashed app, wtf... #noob
            /*if let rewards = rewards {
             self.rewards = rewards
             }
             else if let error = error {
             Crashlytics.sharedInstance().recordError(error)
             }*/
        }
        
    }
    /*func setRewardImg(_ imgString: String) {
        Alamofire.request(imgString).responseImage { response in
            if let imageResult = response.result.value {
                self.imageView?.image = imageResult
            }
        }
    }*/
    fileprivate func rewardForSection(_ index: Int) -> Rewards {
        return rewardsArray![index]
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
