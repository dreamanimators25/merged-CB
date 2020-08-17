//
//  CreateAccountViewController.swift
//  iList Ambassador
//
//  Created by Dmitriy Zhyzhko on 12.09.2018.
//  Copyright © 2018 iList AB. All rights reserved.
//

import UIKit
import Planet

class CreateAccountViewController: UIViewController, CountryPickerViewControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var selectCountryView: UIView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet private weak var companyNameLbl: UITextField!
    
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    
    @IBOutlet weak var datePicjer: UIDatePicker!
    
    var country: Country?
    
    override func viewDidLoad() {
        super.viewDidLoad()

      //  self.navigationController?.navigationBar.barStyle = .blackTranslucent
       
        
        
     // self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "logo_small")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(closeButtonTapped(_:)))
        
        self.makeBarButton()

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectCountry))
        selectCountryView.isUserInteractionEnabled = true
        selectCountryView.addGestureRecognizer(tap)
        
        lastName.delegate = self
        firstName.delegate = self
    }
    
    func makeBarButton()
    {
        self.makeNavigationBar()
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "logo_small")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        let barButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func closeButtonTapped(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.firstName) {
            self.lastName.becomeFirstResponder()
        } else { self.view.endEditing(true) }
        return false
    }
    
    @objc func selectCountry() {
        let viewController = CountryPickerViewController()
        viewController.delegate = self
        
        self.present(viewController, animated: true, completion: nil)
    }

    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        if lastName.text!.isEmpty || firstName.text!.isEmpty {
            let alertController = UIAlertController(title: nil, message: "Please fill in all input fields!", preferredStyle: UIAlertControllerStyle.alert)
        
            alertController.addAction(UIAlertAction(title: "Ok", style:     UIAlertActionStyle.default, handler: nil))
        
            self.present(alertController, animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CreateAccountFinishViewController") as! CreateAccountFinishViewController
            vc.birthday = "\(datePicjer.date.year())-\(datePicjer.date.month())-\(datePicjer.date.day())"
            vc.lastName = lastName.text!
            vc.firstName = firstName.text!
            vc.countryCode = companyNameLbl.text ?? "US"//self.country == nil ? "US" : self.country!.isoCode
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
            
        }
    }
    
    func countryPickerViewControllerDidCancel(_ countryPickerViewController: CountryPickerViewController) {
        
    }
    
    func countryPickerViewController(_ countryPickerViewController: CountryPickerViewController, didSelectCountry country: Country) {
        countryImageView.image = country.image
        countryNameLabel.text = country.name
    
        print("code = \(country.isoCode)")
        self.country = country
        
        countryPickerViewController.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController
{
    func makeNavigationBar()
    {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "scrnshot"), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
    }
    func makeClearNavigationBar()
    {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
}
