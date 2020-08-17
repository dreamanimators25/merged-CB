//
//  UserManager.swift
//  iListAmbassador
//
//  Created by Pontus Andersson on 16/04/15.
//  Copyright (c) 2015 ilist. All rights reserved.
//

import Foundation
import Alamofire
import SimpleKeychain
import FBSDKLoginKit
import Crashlytics

private let kUserDefaultsUserPassword = "kUserDefaultsUserPassword"
private let kUserKeychainKeyPassword = "kUserKeychainKeyPassword"

typealias ImageUploadResponseBlock = (_ imageUrl: String?, _ error: Error?) -> ()
typealias UserPostResponseBlock = (_ user: User?, _ error: Error?, _ alreadyExist: Bool) -> ()
typealias UserResponseBlock = (_ user: User?, _ error: Error?) -> ()
typealias UserAuthResponseBlock = (_ user: User?, _ error: Error?, _ text: String?) -> ()
typealias LoginResponseBlock = (_ refreshToken: String, _ accessToken: String, _ scope: String, _ tokenType: String, _ expiresIn: Int) -> ()
typealias UsersResponseBlock = (_ users: [User]?, _ error: Error?) -> ()

typealias ForgotPasswordResponseBlock = (_ success: Bool, _ error: Error?, _ info: String?) -> ()

typealias ConnectionResponseBlock = (_ connection: Connection?, _ error: Error?) -> ()
typealias ConnectionsResponseBlock = (_ connections: [Connection]?, _ error: Error?) -> ()

typealias UseBlock = (_ number: Int, _ unlim: Bool, _ error: Error?) -> ()
typealias ConnectionRequestSuccessResponseBlock = (_ success: Bool, _ error: Error?) -> ()
typealias ConnectionRequestResponseBlock = (_ connectionRequest: ConnectionRequest?, _ error: Error?) -> ()
typealias ConnectionRequestsResponseBlock = (_ connectionRequests: [ConnectionRequest]?, _ error: Error?) -> ()

typealias SuccessResponseBlock = (_ success: Bool, _ error: Error?) -> ()
typealias TestResponseBlock = (_ users: [User]?, _ error: Error?) -> ()

open class UserManager: BaseManager {
    
    var user: User?
    var connections: [Connection]?
    var connectionRequests: [ConnectionRequest]?
    
    open class var sharedInstance: UserManager {
        struct Singleton {
            static let instance = UserManager()
        }
        return Singleton.instance
    }
    
    func storeUserData(_ user : User) {
        self.user = user
    }
    
    fileprivate func storeUser(_ user: User) {
        self.user = user
        
        updatePushNotificationsInfo()
        
        Crashlytics.sharedInstance().setUserIdentifier("\( user.id )")
        Crashlytics.sharedInstance().setUserEmail(user.email)
        Crashlytics.sharedInstance().setUserName(user.fullName)
    }
    
    fileprivate func updatePushNotificationsInfo() {
        let notificationSettings = UIUserNotificationSettings(types: [.sound, .badge, .alert], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }
    
    func currentAuthorizedUser(_ completion: @escaping (_ user: User?) -> ()) {
        print("CURRENTAUTHORIZEDUSER")
        if hasAccessToken {
            UserManager.sharedInstance.getCurrentUser { (user, _) in
                if let user = user {
                    self.storeUser(user)
                    completion(user)
                } else {
                    completion(nil)
                }
            }
            
        } else if FBSDKAccessToken.current() != nil {
            print("Authenticating with facebook token")
            authenticateWithFacebookToken(FBSDKAccessToken.current().tokenString, facebookResult: nil, completion: { (user, error) in
                if let user = user {
                    completion(user)
                } else if error != nil {
                    print("Authenticating with FB-token failed, reason: \(error.debugDescription)")
                    completion(nil)
                }
            })
        } else {
            
            completion(nil)
        }
    }
    
    // MARK: - Authentication
    
    func authenticateWithUsername(_ username: String, password: String, completion: @escaping UserAuthResponseBlock) {
        
        let router = UserRouter(endpoint: .loginUser(username: username, password: password))
        print("THIS SHOULD NOT HAPPEN")
        
        performRequest1(withRouter: router, { [weak self] (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                print("dict = \(dict)")
                if let dict = dict as? [String:Any] {
                    if dict.description.contains("invalid_grant") || dict.description.contains("Not Found") {
                        
                        completion(nil, nil, "The email or password entered is incorrect")
                        return
                    }
                }
                
                if let dict = dict as? [String:Any],
                    let refreshToken = dict["refresh_token"] as? String,
                    let accessToken = dict["access_token"] as? String,
                    let expireTime = dict["expires_in"] as? Double {
                
                    OAuth2Handler.sharedInstance.update(accessToken: accessToken, refreshToken: refreshToken)
                    print("Access and refresh token have been updated")
                    
                    
                    let time = Date().timeIntervalSince1970
                    let expTime = time + expireTime
                    print(expTime,time)
                    
                    CustomUserDefault.saveTokenTime(data: expTime)
                    
                }
                
                UserManager.sharedInstance.getCurrentUser { (user, error) in
                    if let user = user {
                        self?.storeUser(user)
                        completion(user, nil, nil)
                    } else if let error = error {
                        completion(nil, error, nil)
                    }
                }
            case .failure(let error):
                completion(nil, error, nil)
            }
        })
    }
    
    func newAuthenticateWithFacebookToken(_ facebookToken: String, facebookResult: Any?, completion: @escaping LoginResponseBlock) {
        let parameters = [
            "backend": "facebook",
            "token" : facebookToken,
            "grant_type" : "convert_token",
            "client_id" : BaseManager.credentials.clientId,
            "client_secret" : BaseManager.credentials.clientSecret
        ]
        let router = UserRouter(endpoint: UserEndpoint.facebookLogin(params: parameters))
        Alamofire.request(router)
            .responseJSON { response in
                
                guard response.result.isSuccess else {
                    print("Error while converting token: \(String(describing: response.result.error))")
                    completion(String(), String(), String(), String(), Int())
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any],
                    let refreshToken = responseJSON["refresh_token"] as? String,
                    let accessToken = responseJSON["access_token"] as? String,
                    let scope = responseJSON["scope"] as? String,
                    let tokenType = responseJSON["token_type"] as? String,
                    let expiresIn = responseJSON["expires_in"] as? Int
                    else {
                        print("Assigning dictionary values failed")
                        return
                }
                print("Updating access tokens")
                OAuth2Handler.sharedInstance.update(accessToken: accessToken, refreshToken: refreshToken)
                completion(refreshToken, accessToken, scope, tokenType, expiresIn)
                
                
                return
        }
        
        
    }
    
    func useGift(_ userId: String, rewardId: String) {
        let parameters = [
            "user_id" : userId,
            "reward_id" : rewardId
        ]
        print("params -= \(parameters)")
        let router = UserRouter(endpoint: UserEndpoint.useGift(params: parameters))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                print("gg = \(dict)")
                
            case .failure(let error):
                  print("error = \(error)")
            }
        })
    }
    //http://89.46.81.53/api/brands-nearme/?lat=49.98198198198198&long=36.230583973911365
    func nearbyBrands(lat: String, long: String, success: @escaping (([Brand])->Void)) {
        var router = UserRouter(endpoint: UserEndpoint.nearbyBrands(lat: lat, long: long))

        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                print("gg = \(dict)")
                let responseDict = dict as! [String:Any]
                let connectionRequests = responseDict["data"] as! [String:Any]
                let some = connectionRequests["result"] as! Array<[String:Any]>
                let res = some.map({ Brand(dictionary: $0) })
                success(res)
                print("connectionRequests = \(res)")
            case .failure(let error):
                print("error = \(error)")
            }
        })
    }
    
    func changePsw(_ old: String, _ new: String, onSuccess: @escaping (()->Void), onError: @escaping (()->Void)) {
        let parameters = [
            "old_password" : old,
            "new_password" : new,
            "confirm_new_password" : new
        ]
        print("params -= \(parameters)")
        let router = UserRouter(endpoint: UserEndpoint.changePsw(params: parameters))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            print("result = \(response)")
            switch response.result {
            case .success(let dict):
                print("change psw = \(dict)")
                if response.response?.statusCode == 400 {
                     onError()
                } else {
                    onSuccess()
                }
                
            case .failure(let error):
                print("error = \(error)")
                onError()
            }
        })
    }
    
    func authenticateWithFacebookToken(_ facebookToken: String, facebookResult: Any?, completion: @escaping UserResponseBlock) {
        // We need to set this because email login might change heimdallr token URL
        let parameters = [
            "backend": "facebook",
            "token" : facebookToken,
            "grant_type" : "convert_token",
            "client_id" : BaseManager.credentials.clientId,
            "client_secret" : BaseManager.credentials.clientSecret
        ]
        let router = UserRouter(endpoint: UserEndpoint.facebookLogin(params: parameters))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                
                if let dict = dict as? [String:Any],
                    let refreshToken = dict["refresh_token"] as? String,
                    let accessToken = dict["access_token"] as? String {
                    OAuth2Handler.sharedInstance.update(accessToken: accessToken, refreshToken: refreshToken)
                }
                
                UserManager.sharedInstance.getCurrentUser { (user, error) in
                    if let user = user {
                        self.storeUser(user)
                        completion(user, nil)
                    } else if let error = error {
                        completion(nil, error)
                    }
                }
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    func fetchFacebookUserInfo(_ completion: @escaping UserResponseBlock) {
        
        let parameters = ["fields" : "id, first_name, last_name, picture, email"]
        FBSDKGraphRequest.init(graphPath: "me", parameters: parameters).start { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
            
            if let error = error {
                debugPrint("FB Users info Error: \( error.localizedDescription )")
            } else {
                let accessToken: FBSDKAccessToken = FBSDKAccessToken.current()
                //print("Facebook authentication done, updating FB access token with: \(accessToken.tokenString)")
                FBSDKAccessToken.setCurrent(accessToken)
               
                //ADAMS
                self.newAuthenticateWithFacebookToken(accessToken.tokenString, facebookResult: result, completion: { refreshToken, accessToken, scope, tokenType, expiresIn in
                    
                    print("Beginning login attempt with converted token:")
                    UserManager.sharedInstance.getCurrentUser { (user, error) in
                        if let user = user {
                            self.storeUser(user)
                            completion(self.user, error)
                        } else if error != nil {
                            completion(nil, error)
                        }
                    }
                    print("Login attempt finished")
                    
                    
                    completion(self.user, error)
                
                
                })
                //self.authenticateWithFacebookToken(accessToken.tokenString, facebookResult: result, completion: completion)
            }
            
        }
    }
    
    func registerWithUsername(_ param: [String:String], completion: @escaping UserPostResponseBlock) {
        let router = UserRouter(endpoint: .registerUser(params: param))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                let userDict = dict as! [String:Any]
                let email = userDict.description
                let exist = email.contains("User with this email address already exists")
                let user = User(dictionary: userDict)
                
                if !exist {
                    self.authenticateWithUsername(param["email"]!, password: param["password"]!, completion: { (user, error, text) in
                        completion(user, error, exist)
                    })
                    return
                }
                completion(user, nil, exist)
            case .failure(let error):
                completion(nil, error, false)
            }
        })
    }
    
    func logoutUserWithCompletion(_ completion: (() -> ())?) {
        Keychain.clearAccessToken()

        user = nil
        connections = nil
        connectionRequests = nil
        
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        if let completion = completion {
            completion()
        }
    }
    
    // MARK: - Forgot Password
    
    func restorePasswordWithEmail(_ email: String, completion:@escaping ForgotPasswordResponseBlock) {
        let router = UserRouter(endpoint: .sendRestorePasswordToEmail(email: email))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                let json = response.result.value as! Dictionary<String, Any>
                
                print("res = \(json)")
                completion(true, nil, json["detail"] as? String)
            case .failure(let error):
                completion(false, error, nil)
            }
        })
    }
    
    // MARK: - User
    
    func removeUser(_ completion: @escaping UserResponseBlock) {
        let router = UserRouter(endpoint: .removeUser)

        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                Keychain.clearAccessToken()
                
                self.user = nil
                self.connections = nil
                self.connectionRequests = nil
                
                print("success = \(dict)")
                completion(nil, nil)
            case .failure(let error):
                print("error = \(error)")
                completion(nil, error)
            }
        })
    }
    
    func getCurrentUser(_ completion: @escaping UserResponseBlock) {
        print("GETCURRENTUSER")
        let router = UserRouter(endpoint: .getCurrentUser)
        
        performRequest1(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                let userDict = dict as! [String:Any]
                let user = User(dictionary: userDict)
                completion(user, nil)
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    func getUserWithId(_ userId: Int, completion: @escaping UserResponseBlock) {
        print("GETUSERWITHID")
        let router = UserRouter(endpoint: .getUser(userId: userId))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                let userDict = dict as! [String:Any]
                let user = User(dictionary: userDict)
                completion(user, nil)
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    func updateUser(_ user: User, completion: @escaping UserResponseBlock) {
        print("UPDATEUSER")
        let router = UserRouter(endpoint: .updateUser(user: user))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                let userDict = dict as! [String:Any]
                let user = User(dictionary: userDict)
                completion(user, nil)
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    func searchUsersWithQuery(_ query: String, page: Int, pageSize: Int, completion: @escaping UsersResponseBlock) {
        let router = UserRouter(endpoint: .searchUsers(query: query, page: page, pageSize: pageSize))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                let responseDict = dict as! [String:Any]
                let usersArray = responseDict["data"] as! Array<[String:Any]>
                let users = usersArray.map({ User(dictionary: $0) })
                completion(users, nil)
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    func updateProfilePictureForUser(_ user: User, profilePicture: UIImage, completion: @escaping ImageUploadResponseBlock) {
        guard let pictureData: Data = profilePicture.pngData() else {
            let error = NSError(domain: "Profile Image", code: 400, userInfo: [NSLocalizedDescriptionKey:"Profile Image Upload Failure"])
            completion(nil, error)
            return
        }
        let dateString = "\(Date())"
        let imageFileName = "\(user.id)-\(dateString.removeWhitespace()).png"
        
        let router = UserRouter(endpoint: .uploadNewProfilePic(userId: user.id))

        
        var request: URLRequest?
        do {
            request = try router.asURLRequest()
            request = try OAuth2Handler.sharedInstance.adapt(request!)
        } catch {
            print("error authenticating request: \(error)")
        }
        
        guard let authenticatedRequest = request else {
            completion(nil, nil)
            return
        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData: MultipartFormData) in
            multipartFormData.append(pictureData, withName: "profile_image", fileName: imageFileName, mimeType: "image/png")
        }, with: authenticatedRequest, encodingCompletion: { (manager: SessionManager.MultipartFormDataEncodingResult) in
            switch manager {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        switch response.result {
                        case .success(let dict):
                            let responseDict = dict as! [String:Any]
                            let profileImageUrlString = responseDict["profile_image"] as! String
                            completion(profileImageUrlString, nil)
                        case .failure(let error):
                            completion(nil, error)
                        }
                }
            case .failure(_):
                let error = NSError(domain: "Profile Image Encoding", code: 400, userInfo: [NSLocalizedDescriptionKey:"Failed to encode profile image"])
                completion(nil, error)
            }
        })
    }
    
    func updateBackgroundPhotoForUser(_ user: User, backgroundPhoto: UIImage, completion: @escaping ImageUploadResponseBlock) {
        guard let pictureData: Data = backgroundPhoto.pngData() else {
            let error = NSError(domain: "bg Image", code: 400, userInfo: [NSLocalizedDescriptionKey:"bg Image Upload Failure"])
            completion(nil, error)
            return
        }
        let dateString = "\(Date())"
        let imageFileName = "\(user.id)-\(dateString.removeWhitespace()).png"
        let router = UserRouter(endpoint: .uploadNewBackgroundPic(userId: user.id))
        
        var request: URLRequest?
        do {
            request = try router.asURLRequest()
            request = try OAuth2Handler.sharedInstance.adapt(request!)
        } catch {
            print("error authenticating request: \(error)")
        }
        
        guard let authenticatedRequest = request else {
            completion(nil, nil)
            return
        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData: MultipartFormData) in
            multipartFormData.append(pictureData, withName: "profile_background", fileName: imageFileName, mimeType: "image/png")
        }, with: authenticatedRequest, encodingCompletion: { (manager: SessionManager.MultipartFormDataEncodingResult) in
            switch manager {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch response.result {
                    case .success(let dict):
                         let responseDict = dict as! [String:Any]
                         let profileImageUrlString = responseDict["profile_background"] as! String
                        completion(profileImageUrlString, nil)
                    case .failure(let error):
                        completion(nil, error)
                    }
                }
            case .failure(_):
                let error = NSError(domain: "Profile Image Encoding", code: 400, userInfo: [NSLocalizedDescriptionKey:"Failed to encode profile image"])
                completion(nil, error)
            }
        })
        
    }
    
    // MARK: - Connections
    
    fileprivate func logoutUser() {
        UserManager.sharedInstance.logoutUserWithCompletion {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.navigateToLogin()
            }
        }
    }
    
    func getGroupDetails(_ user: User, completion: @escaping ([[String:Any]]?) -> Void) {
        let router = UserRouter(endpoint: .getGroupDetails(userId: user.id ))
        performRequest(withRouter: router) { (response) in
            switch response.result {
            case .success(let dict):
                print("success")
            completion(dict as? [[String : Any]] ?? [])
            case .failure(let error):
                print(error.localizedDescription)
                completion([])
            }
        }
    }
    
    func getConnectionsForUser(_ user: User, completion: @escaping ConnectionsResponseBlock) {
        let router = UserRouter(endpoint: .getConnectionsForUser(userId: user.id))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                
                let statusCode = response.response?.statusCode
                print("\(String(describing: statusCode))")
                if statusCode! >= 300 {
                    completion(nil, nil)
                }
                else {
                let responseDict = dict as! [String:Any]
                let connectionsArray = responseDict["data"] as! Array<[String:Any]>
                let connections = connectionsArray.map({ Connection(dictionary: $0) })
                    
                if user.isCurrentUser {
                    // Save current users connections
                    self.connections = connections
                } else { self.connections = connections }
                completion(connections, nil)
                }
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    func deleteConnectionForUser(_ user: User, connection: Connection, completion: @escaping ConnectionResponseBlock) {
        let router = UserRouter(endpoint: .deleteConnectionForUser(userId: user.id, connectionId: connection.id))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
                
            case .success(let dict):
                let statusCode = response.response?.statusCode
                print("\(String(describing: statusCode))")
                if statusCode! <= 300 {
                    completion(nil, nil)
                }
                else {
                    let responseDict = dict as! [String:Any]
                    let connectionsDict = responseDict["data"] as! [String:Any]
                    let connection = Connection(dictionary: connectionsDict)
                completion(connection, nil)
                }
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    func getConnectionRequestForUser(_ user: User, completion: @escaping ConnectionRequestsResponseBlock) {
        let router = UserRouter(endpoint: .getConnectionRequestsForUser(userId: user.id))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                let responseDict = dict as! [String:Any]
                let connectionRequestsArray = responseDict["data"] as! Array<[String:Any]>
                let connectionRequests = connectionRequestsArray.map({ ConnectionRequest(dictionary: $0) })
                completion(connectionRequests, nil)
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    func useCoupon(_ ambassadorshipContentId: String, pageId: String, completion: @escaping UseBlock) {
        let router = UserRouter(endpoint: .useCoupon(ambassadorshipContentId: pageId, pageId: ambassadorshipContentId))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
           
                let res = dict as! [String : Any]
                print("res \(response)")
                print("response \(res["number_of_uses"])")
                if let count = res["number_of_uses"] {
                    print("COUNT = \(count)")
                    completion(count as! Int, false, nil)
                }
                //completion(true, nil)
            case .failure(let error):
                print("error \(error)")
                completion(-1, false, error)
            }
        })
    }
    
    func tryCoupon(_ ambassadorshipContentId: String, pageId: String, completion: @escaping UseBlock) {
        let router = UserRouter(endpoint: .tryCoupon(ambassadorshipContentId: pageId, pageId: ambassadorshipContentId))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                
                let res = dict as! [String : Any]
                print("res \(response)")
                print("response \(res["number_of_uses"])")
                if let count = res["number_of_uses"] {
                    print("COUNT = \(count)")
                    completion(count as! Int, false, nil)
                }
            //completion(true, nil)
            case .failure(let error):
                print("error \(error)")
                completion(-1, false, error)
            }
        })
    }
    
    func createConnectionRequestForUser(_ user: User, targetUser: User, completion: @escaping ConnectionRequestSuccessResponseBlock) {
        let router = UserRouter(endpoint: .createConnectionForUser(userId: user.id, targetUserId: targetUser.id))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        })
    }
    
    func updateConnectionRequestForUser(_ user: User, connectionRequest: ConnectionRequest, connectionRequestAction: ConnectionRequestAction, completion: @escaping ConnectionRequestResponseBlock) {
        let router = UserRouter(endpoint: .updateConnectionRequestForUser(userId: user.id, connectionRequestId: connectionRequest.id, connectionRequestAction: connectionRequestAction.rawValue))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                let connectionRequestDict = dict as! [String:Any]
                let connectionRequest = ConnectionRequest(dictionary: connectionRequestDict)
                completion(connectionRequest, nil)
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    func registerPushToken(_ token: String, completion: @escaping SuccessResponseBlock) {
        if let user = user {
            let router = UserRouter(endpoint: .registerPushToken(token: token, id:user.id))
            performRequest(withRouter: router, { (response: DataResponse<Any>) in
                switch response.result {
                case .success(_):
                    completion(true, nil)
                case .failure(let error):
                    completion(false, error)
                }
            })
        }
    }
}

public extension User {
    
    var isCurrentUser: Bool {
        get {
            guard let currentUser = UserManager.sharedInstance.user else {
                return false
            }
            return (self.id == currentUser.id)
        }
    }
    
    func defaultImage() -> UIImage? {
        if gender == .Male {
            return UIImage(named: "defaultmale")
        } else if gender == .Female {
            return UIImage(named: "defaultfemale")
        } else {
            return UIImage(named: "defaultneutralgender")
        }
    }
}

public extension Connection {
    var isCurrentUsersRequest: Bool {
        get {
            guard let currentUser = UserManager.sharedInstance.user else { return false }
            return (self.fromUser.id == currentUser.id)
        }
    }
    var user: User {
        get {
            if isCurrentUsersRequest {
                return toUser
            }
            return fromUser
        }
    }
}

public extension ConnectionRequest {
    var isCurrentUsersRequest: Bool {
        get {
            guard let currentUser = UserManager.sharedInstance.user else { return false }
            return (self.fromUser.id == currentUser.id)
        }
    }
    var user: User {
        get {
            if isCurrentUsersRequest {
                return toUser
            }
            return fromUser
        }
    }
    
    var isRejected: Bool {
        get {
            return self.rejected != nil
        }
    }
}
