//
//  User.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 06/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import DateTools

private let kAPIKeyId = "id"
private let kAPIKeyEmail = "email"
private let kAPIKeyFirstName = "first_name"
private let kAPIKeyLastName = "last_name"
private let kAPIKeyGender = "gender"
private let kAPIKeyBirthDate = "birth_date"
private let kAPIKeyCreated = "created"
private let kAPIKeyProfileImage = "profile_image"
private let kAPIKeyProfileBackgroundImage = "profile_background"
private let kAPIKeyOver21 = "over_21"
private let kAPIKeyShowWallet = "show_wallet_to_others"
private let kAPIKeyShowChannels = "show_channels_to_others"
private let kAPIKeySearchable = "searchable"

open class User {
    
    var id: Int = 0
    var email: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var fullName: String {
        return firstName + " " + lastName
    }
    
    var gender: Gender?
    var profileImage: String?
    var profileBackgroundImage: String?
    
    var birthDate: Date?
    var created: Date?
    
    var hasProfilePicture: Bool {
        get {
            return profileImage != nil
        }
    }
    
    var show_wallet_to_others: Bool?
    var show_channels_to_others: Bool?
    var over_21: Bool?
    var searchable: Bool?
    
    init() {
        firstName = "Some guy"
        lastName = "Some anme"
    }
    
    init(dictionary: [String:Any]) {
        
        if let search = dictionary[kAPIKeySearchable] as? Bool {
            self.searchable = search
        }
        if let over = dictionary[kAPIKeyOver21] as? Bool {
            self.over_21 = over
        }
        if let showWallet = dictionary[kAPIKeyShowWallet] as? Bool {
            self.show_wallet_to_others = showWallet
        }
        if let showChannels = dictionary[kAPIKeyShowChannels] as? Bool {
            self.show_channels_to_others = showChannels
        }
        if let id = dictionary[kAPIKeyId] as? Int {
            self.id = id
            CustomUserDefault.setUserId(data: id)
        }
        if let email = dictionary[kAPIKeyEmail] as? String {
            self.email = email
        }
        if let firstName = dictionary[kAPIKeyFirstName] as? String {
            self.firstName = firstName
        }
        if let lastName = dictionary[kAPIKeyLastName] as? String {
            self.lastName = lastName
        }
        if let genderString = dictionary[kAPIKeyGender] as? String, let gender = Gender(rawValue: genderString) {
            self.gender = gender
        }
        if let profileImage = dictionary[kAPIKeyProfileImage] as? String {
            self.profileImage = profileImage
        }
        if let profileBackgroundImage = dictionary[kAPIKeyProfileBackgroundImage] as? String {
            self.profileBackgroundImage = profileBackgroundImage
        }
        if let birthDate = dictionary[kAPIKeyBirthDate] as? String {
            self.birthDate = NSDate(string: birthDate, formatString: APIDefinitions.FullDateFormat) as Date?
        }
        if let created = dictionary[kAPIKeyCreated] as? String {
            self.created = NSDate(string: created, formatString: APIDefinitions.FullDateFormat) as Date?
        }
    }
    func setProfilePicture(_ imageUrl:String) {
        self.profileImage = imageUrl
    }
    func setBackgroundPhoto(_ imageUrl:String) {
        self.profileBackgroundImage = imageUrl
    }
    /**
     Converts user to dictionary. Only include what can be updated in the back-end API.
     */
    func toDictionary() -> [String:Any] {
        var dict: [String: AnyObject] = [:]
        dict[kAPIKeyId] = id as AnyObject?
        dict[kAPIKeyEmail] = email as AnyObject?
        dict[kAPIKeyFirstName] = firstName as AnyObject?
        dict[kAPIKeyLastName] = lastName as AnyObject?
        dict[kAPIKeyOver21] = over_21 as AnyObject?
        dict[kAPIKeyShowWallet] = show_wallet_to_others as AnyObject?
        dict[kAPIKeyShowChannels] = show_channels_to_others as AnyObject?
        dict[kAPIKeySearchable] = searchable as AnyObject?
        
        if let gender = gender {
            dict[kAPIKeyGender] = gender.rawValue as AnyObject?
        }
        if let birthDate = birthDate {
            dict[kAPIKeyBirthDate] = (birthDate as NSDate).formattedDate(withFormat: APIDefinitions.FullDateFormat) as AnyObject?
        }
        return dict
    }
    
}

/*
 {
	"id": 1,
	"is_superuser": true,
	"created": "2016-03-21 15:25:26 UTC+0000",
	"updated": "2016-04-12 09:45:11 UTC+0000",
	"email": "simon@ilistambassador.com",
	"is_staff": true,
	"is_active": true,
	"first_name": "",
	"last_name": "",
	"gender": null,
	"birth_date": null,
	"allow_crossover": true,
	"profile_image": "https://ilistambassador.s3.amazonaws.com:443/user/profile_images/IMG_2176.JPG",
	"profile_background": "https://ilistambassador.s3.amazonaws.com:443/user/profile_backgrounds/iPhone_Image_2456A6.jpg"
 }
 */

class CustomUserDefault: NSObject {
    
    static  func setUserId(data : Int?) {
        UserDefaults.standard.set(data, forKey: "UserId")
    }
    
    static  func getUserId()-> Int? {
        return UserDefaults.standard.object(forKey: "UserId") as? Int ?? 0
    }
    
    static func removeUserId() {
        UserDefaults.standard.removeObject(forKey: "UserId")
    }
    
    //set
    static func saveUserData(modal : User) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: modal.toDictionary())
        UserDefaults.standard.set(encodedData, forKey: "UserData")
        UserDefaults.standard.synchronize()
    }
    
    //get
    static func getUserData() -> User? {
        if let data = UserDefaults.standard.data(forKey: "UserData"),
            let myLoginData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] {
            let loginData = User.init(dictionary: myLoginData)
            UserDefaults.standard.synchronize()
            return loginData
        } else {
            UserDefaults.standard.synchronize()
            return nil
        }
    }
    
    //Remove Login Data
    static func removeLoginData() {
        UserDefaults.standard.removeObject(forKey: "UserData")
    }
    
    //set Token Time
    static func saveTokenTime(data : Double?) {
        UserDefaults.standard.set(data, forKey: "TokenTime")
    }
    
    //get Token Time
    static  func getTokenTime()-> Double? {
        return UserDefaults.standard.object(forKey: "TokenTime") as? Double ?? 0.0
    }
    
    //Remove Toke Time
    static func removeTokenTime() {
        UserDefaults.standard.removeObject(forKey: "TokenTime")
    }
    
    //set UserName
    static func saveUserName(name : String) {
        UserDefaults.standard.set(name, forKey: "UserName")
        UserDefaults.standard.synchronize()
    }
    
    //get UserName
    static func getUserName() -> String? {
        return UserDefaults.standard.object(forKey: "UserName") as? String ?? ""
    }
    
    //Remove UserName
    static func removeUserName() {
        UserDefaults.standard.removeObject(forKey: "UserName")
    }
    
    //set Password
    static func saveUserPassword(password : String) {
        UserDefaults.standard.set(password, forKey: "UserPassword")
        UserDefaults.standard.synchronize()
    }
    
    //get Password
    static func getUserPassword() -> String? {
        return UserDefaults.standard.object(forKey: "UserPassword") as? String ?? "0"
    }
    
    //Remove Password
    static func removeUserPassword() {
        UserDefaults.standard.removeObject(forKey: "UserPassword")
    }
    
    
}
