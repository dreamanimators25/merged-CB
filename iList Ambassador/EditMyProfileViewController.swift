//
//  EditMyProfileViewController.swift
//  iList Ambassador
//
//  Created by Dmitriy Zhyzhko on 05.03.2019.
//  Copyright © 2019 iList AB. All rights reserved.
//

import Foundation
import UIKit

final class EditMyProfileViewController: UIViewController {
     var user: User? = UserManager.sharedInstance.user
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var unsearchableButton: UIButton!
    @IBOutlet weak var overButtom: UIButton!
    
    @IBOutlet weak var womanButton: UIButton!
    @IBOutlet weak var manButton: UIButton!
    
    @IBOutlet weak var genderLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    @IBAction func onBackPressed(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.init("showMenu"), object: nil, userInfo: ["data" : true])
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onChangePressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func malePressed(_ sender: UIButton) {
        genderLabel.text = "Male"
        womanButton.setImage(UIImage(named: "female-blank1"), for: .normal)
        manButton.setImage(UIImage(named: "male-full1"), for: .normal)
        user?.gender = .Male
        updateUserWithGenderButtonStatus(user!, sender: sender)
    }
    
    @IBAction func femalePressed(_ sender: UIButton) {
        genderLabel.text = "Female"
        womanButton.setImage(UIImage(named: "female-full1"), for: .normal)
        manButton.setImage(UIImage(named: "male-blank1"), for: .normal)
        user?.gender = .Female
        updateUserWithGenderButtonStatus(user!, sender: sender)
    }
    
    @IBAction func overPressed(_ sender: UIButton) {
        user?.over_21 = !(user?.over_21)!
        overButtom.setImage(UIImage(named: user!.over_21! ? "settings-option-full1" : "settings-option-blank1"), for: .normal)
        updateUserWithSwitchButtonStatus(user!, sender: sender)
    }
    
    @IBAction func unsearchPressed(_ sender: UIButton) {
        guard user?.searchable != nil else { return }
        print(user?.searchable!)
        user?.searchable = !(user?.searchable)!
        unsearchableButton.setImage(UIImage(named: user!.searchable! ? "settings-option-full1" : "settings-option-blank1"), for: .normal)
        updateUserWithSwitchButtonStatus(user!, sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.post(name: Notification.Name.init("showMenu"), object: nil, userInfo: ["data" : false])
        self.makeBarButton()
        if let user = user {
            setImageForUser(user)
            if (user.gender == .Female) {
                womanButton.setImage(UIImage(named: "female-full1"), for: .normal)
                manButton.setImage(UIImage(named: "male-blank1"), for: .normal)
            } else {
                womanButton.setImage(UIImage(named: "female-blank1"), for: .normal)
                manButton.setImage(UIImage(named: "male-full1"), for: .normal)
            }
            unsearchableButton.setImage(UIImage(named: user.searchable! ? "settings-option-full1" : "settings-option-blank1"), for: .normal)
            overButtom.setImage(UIImage(named: user.over_21! ? "settings-option-full1" : "settings-option-blank1"), for: .normal)
            genderLabel.text = user.gender == .Female ? "Female" : "Male"
        }
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
        
        setupImagePicker()
    }
    func makeBarButton()
    {
        self.makeNavigationBar()
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "left-arrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        let barButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.leftBarButtonItem = barButton
    }
    @objc func closeButtonTapped(_ sender: AnyObject?) {
        NotificationCenter.default.post(name: Notification.Name.init("showMenu"), object: nil, userInfo: ["data" : true])
        navigationController?.popViewController(animated: true)
        
    }
    
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
    }
    
    func setImageForUser(_ user: User) {
        if let profileImageUrlString = user.profileImage, let profileImageUrl = URL(string: profileImageUrlString) {
            setImageFromUrl(profileImageUrl)
        } else {
            setDefaultImageForUser(user)
        }
    }
    
    func setDefaultImageForUser(_ user: User) {
        imageView.af_cancelImageRequest()
        imageView.image = user.defaultImage()
        imageView.backgroundColor = Color.backgroundColorFadedDark()
    }
    
    func setImageFromUrl(_ url: URL) {
        imageView.af_setImage(withURL: url)
    }
    
    fileprivate func updateUserWithGenderButtonStatus(_ user: User, sender: UIButton) {
        UserManager.sharedInstance.updateUser(user) { [weak self] (returnedUser: User?, error: Error?) in
            if returnedUser?.id != nil {
                self?.user = returnedUser
                
            }
        }
        print("Returned user gender:")
        print(self.user?.gender!)
    }
    
    fileprivate func updateUserWithSwitchButtonStatus(_ user: User, sender: UIButton) {
        UserManager.sharedInstance.updateUser(user) { [weak self] (returnedUser: User?, error: Error?) in
            if returnedUser?.id != nil {
                self?.user = returnedUser
            }
        }
    }
}


extension EditMyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: UIImage?
        if info[UIImagePickerController.InfoKey.editedImage.rawValue] != nil {
            image = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage
        } else if info[UIImagePickerController.InfoKey.originalImage.rawValue] != nil {
            image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
        }
        if let selectedImage = image {
            didSelectProfilePicture(selectedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func didSelectProfilePicture(_ image: UIImage) {
        let newImage = image.resizeImage(imageView.frame.size.width*3)
        imageView.image = newImage
        if let user = self.user {
            UserManager.sharedInstance.updateProfilePictureForUser(user, profilePicture: newImage, completion:{(imageUrl, error) in
                if let url = imageUrl {
                    DispatchQueue.main.async(execute: {
                        if let user = self.user {
                            user.setProfilePicture(url)
                        }
                    })
                } else {
                 
                }
            })
        }
    }
}
