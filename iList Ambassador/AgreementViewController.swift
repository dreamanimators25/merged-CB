//
//  AgreementViewController.swift
//  iList Ambassador
//
//  Created by Максим Власенко on 7/17/18.
//  Copyright © 2018 iList AB. All rights reserved.
//

import UIKit

class AgreementViewController: UIViewController {

    var closure: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func userAgreement(_ sender: UIButton) {
        if let url = URL(string: "http://www.jokk.app/agreementsv") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                // Fallback on earlier versions
            }
        }
    }
    @IBAction func privacyPolicy(_ sender: UIButton) {
        if let url = URL(string: "http://www.jokk.app/privacysv") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                // Fallback on earlier versions
            }
        }
    }
    @IBAction func gdprAgree(_ sender: UIButton) {
        if let url = URL(string: "http://www.jokk.app/gdprsv") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func agreeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: closure)

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
