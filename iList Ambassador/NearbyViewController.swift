//
//  NearbyViewController.swift
//  iList Ambassador
//
//  Created by Dmitriy on 3/12/19.
//  Copyright © 2019 iList AB. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

protocol BrandAddedProtocol {
    func brAdded(brand: Ambassadorship?)
}

final class NearbyViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var progress: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
  let locationManager = CLLocationManager()
    
    var items = [Brand] ()
    
    var delegate: BrandAddedProtocol?
    
    var isFound = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.register(UINib(nibName: UserTableViewCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: UserTableViewCell.cellIdentifier)
        
        // For use when the app is open & in the background
        locationManager.requestAlwaysAuthorization()
        
        // For use when the app is open
        //locationManager.requestWhenInUseAuthorization()
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
        }
    }
    
    // Print out the location to the console
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            isFound = true
            UserManager.sharedInstance.nearbyBrands(lat: String("\(location.coordinate.latitude)"),
                                                    long: String("\(location.coordinate.longitude)"),
                                                    success: { item in
                                                        self.progress.stopAnimating()
                                                        self.items = item
                                                        self.tableView.reloadData()
            })
            
            
//            UserManager.sharedInstance.nearbyBrands(lat: String("-44.04040"),
//                                                    long: String("-49.04040"),
//                                                    success: { item in
//                                                        self.progress.stopAnimating()
//                                                        self.items = item
//                                                        self.tableView.reloadData()
//            })
            
            print(location.coordinate)
        }
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("aaa = \(status.rawValue)")
        if(status == CLAuthorizationStatus.denied) {
            showDialog("Permission denied by user")
            //showLocationDisabledPopUp()
        } else if (status == CLAuthorizationStatus.notDetermined) {
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            print("notDetermined)")
        } else if (status == CLAuthorizationStatus.restricted) {
            print("restricted)")
        } else if (status == CLAuthorizationStatus.authorizedWhenInUse) {
            
        } else if (status == CLAuthorizationStatus.authorizedAlways) {
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}


extension NearbyViewController: UITableViewDelegate, UITableViewDataSource, BrandConnectDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableViewStyler.defaultUserCellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        TableViewStyler.removeSeparatorInsetsForCell(cell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.cellIdentifier, for: indexPath) as! UserTableViewCell
        let user = items[indexPath.row]
        cell.nameLabel.text = user.name

         let profilePictureString = user.logotypeUrl
         if let profilePictureUrl = URL(string: profilePictureString) {
            cell.profilePictureImageView.af_setImage(withURL: profilePictureUrl)
         }
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let brand = items[indexPath.row]
        if !brand.isPublic {
            let brandConnectViewController = BrandConnectViewController()
            brandConnectViewController.delegate = self
            brandConnectViewController.imageUrl = URL(string: brand.logotypeUrl)
            present(brandConnectViewController, animated: true, completion: nil)
        } else {
            AmbassadorshipManager.sharedInstance.requestAmbassadorhipWithCode(brand.code, completion: {(ambassadorship, error, code) in
                if let ambassadorship = ambassadorship {
                    self.delegate?.brAdded(brand: ambassadorship)
                    let contentViewController = UIStoryboard(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "ContentController") as! ContentSetupViewController
                    contentViewController.ambassadorship = ambassadorship
                    contentViewController.user = UserManager.sharedInstance.user
            
                    
                    //present(contentViewController, animated: true, completion: nil)
                    self.navigationController?.pushViewController(contentViewController, animated: true)
                } else {
                   
                }
            })
        }
    }
    
    func successfullySignForNewAmbassadorship(_ ambassador: Ambassadorship) {
        self.delegate?.brAdded(brand: ambassador)
        let contentViewController = UIStoryboard(name: "Content", bundle: nil).instantiateViewController(withIdentifier: "ContentController") as! ContentSetupViewController
        contentViewController.ambassadorship = ambassador
        contentViewController.user = UserManager.sharedInstance.user
        
        
        //present(contentViewController, animated: true, completion: nil)
        navigationController?.pushViewController(contentViewController, animated: true)
    }
    
    func showDialog(_ message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
