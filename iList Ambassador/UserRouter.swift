//
//  UserRouter.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 26/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Alamofire

public enum UserEndpoint {
    
    case getCurrentUser
    case getUser(userId: Int)
    case updateUser(user: User)
    
    case getConnectionsForUser(userId: Int)
    case getConnectionRequestsForUser(userId: Int)
    case deleteConnectionForUser(userId: Int, connectionId: Int)
    case updateConnectionRequestForUser(userId: Int, connectionRequestId: Int, connectionRequestAction: String)
    case createConnectionForUser(userId: Int, targetUserId: Int)
    case updateConnectionForUser(userId: Int, connectionId: Int)
    
    case changePsw(params: [String:String])
    case useGift(params: [String:String])
    case useCoupon(ambassadorshipContentId: String, pageId: String)
    case tryCoupon(ambassadorshipContentId: String, pageId: String)
    case loginUser(username: String, password: String)
    case registerUser(params: [String:String])
    case facebookLogin(params: [String:String])
    case registerForPushNotification(token: String) // We want push notifications on user endpoint (or some other endpoint) instead of it's own endpoint.
    case searchUsers(query: String, page: Int, pageSize: Int)
    case removeUser
    case uploadNewProfilePic(userId: Int)
    case uploadNewBackgroundPic(userId: Int)
    
    case sendRestorePasswordToEmail(email: String)
    
    case nearbyBrands(lat: String, long: String)
    case registerPushToken(token: String, id: Int)
    case updatePushToken(token: String, userId: String)
    
    case getGroupDetails(userId: Int) //s
}

open class UserRouter: BaseRouter {
    
    var endpoint: UserEndpoint
    
    public init(endpoint: UserEndpoint) {
        self.endpoint = endpoint
        super.init()
    }
    
    override open var method: HTTPMethod {
        switch endpoint {
        case .getCurrentUser: return .get
        case .getUser: return .get
        case .updateUser: return .patch
            
        case .getConnectionsForUser: return .get
        case .getConnectionRequestsForUser: return .get
        case .deleteConnectionForUser: return .delete
        case .updateConnectionRequestForUser: return .put
        case .createConnectionForUser: return .post
        case .updateConnectionForUser: return .put
        case .removeUser: return .put
            
        case .loginUser: return .post
        case .registerUser: return .post
        case .facebookLogin: return .post
        case .registerForPushNotification: return .post
        case .searchUsers: return .get
            
        case .uploadNewProfilePic: return .patch
        case .uploadNewBackgroundPic: return .patch
            
        case .sendRestorePasswordToEmail: return .post
            
        case .registerPushToken: return .put
        case .useCoupon: return .get
        case .useGift: return .patch
        case .tryCoupon: return .patch
        case .updatePushToken: return .put
        case .changePsw: return .patch
        case .nearbyBrands: return .get
        
        case .getGroupDetails: return .get //s
        }
    }
    
    override open var path: String {
        switch endpoint {
        case .getCurrentUser: return "users/me/" 
        case .getUser(let userId): return "users/\(userId)/"
        case .updateUser(let user): return "users/\(user.id)/"
            
        case .getConnectionsForUser(let userId): return "users/\(userId)/friends/"
        case .getConnectionRequestsForUser(let userId): return "users/\(userId)/friend-requests/"
        case .updateConnectionRequestForUser(let userId, let connectionRequestId, _): return "users/\(userId)/friend-requests/\(connectionRequestId)/"
        case .deleteConnectionForUser(let userId, let connectionId): return "users/\(userId)/friends/\(connectionId)/"
        case .createConnectionForUser(let userId, _): return "users/\(userId)/friend-requests/"
        case .updateConnectionForUser(let userId, let connectionId): return "users/\(userId)/friend-requests/\(connectionId)/"
         
        case .removeUser: return "delete-account/"
        case .loginUser(_, _): return "o/token/"
        case .registerUser(_): return "users/"
        case .facebookLogin: return "o/convert-token/"
        case .registerForPushNotification(_): return "users/push/"
        case .searchUsers(_, _, _): return "users/"
            
        case .uploadNewProfilePic(let userId): return "users/\(userId)/profile-image/"
        case .uploadNewBackgroundPic(let userId): return "users/\(userId)/background-image/"
            
        case .useCoupon(let ambassadorshipContentId, let pageId): return "use-page/\(ambassadorshipContentId)/ambassador/\(pageId)/"
            
        case .tryCoupon(let ambassadorshipContentId, let pageId): return "use-page/\(ambassadorshipContentId)/ambassador/\(pageId)/"
            
        case .sendRestorePasswordToEmail(_): return "users/restore-password/"
            
        case .registerPushToken(_, let userId): return "users/\(userId)/register-device/ios/"
        case .useGift: return "use-reward/"
        case .updatePushToken(_, let userId): return "users/\(userId)/updateFirebaseToken/"
        case .changePsw(let params): return "users/change-password/"
        case .nearbyBrands(_ , _): return "brands-nearme/"
        
        case .getGroupDetails(let userId): return "users/\(userId)/groups/"
        }
    }
    
    override open var parameters: Parameters? {
        switch endpoint {
        case .updateConnectionRequestForUser(_, _, let connectionRequestAction):
            return ["action" : connectionRequestAction as AnyObject]
        case .createConnectionForUser(let userId, let targetUserId):
            return ["from_user" : userId as AnyObject, "to_user" : targetUserId as AnyObject]
        case .loginUser(let username, let password):
            return [
                "username" : username,
                "password" : password,
                "grant_type" : "password",
                "client_id" : iListOAuthClientCredentials.getClientId(),
                "client_secret" : iListOAuthClientCredentials.getClientSecret()
            ]
        case .registerUser(let params):
            return params as Parameters
        case .facebookLogin(let params):
            return params as Parameters
        case .registerForPushNotification(let token):
            return ["token" : token as AnyObject]
        case .nearbyBrands(let lat, let long):
            return ["lat" : lat as AnyObject, "long" : long as AnyObject]
        case .searchUsers(let query, let page, let pageSize):
            return ["query" : query as AnyObject, "page" : page as AnyObject, "page_size" : pageSize as AnyObject]
        case .sendRestorePasswordToEmail(let email):
            return ["email" : email as AnyObject]
        case .updateUser(let user):
            return user.toDictionary()
        case .registerPushToken(let token,_):
            let uuid = UIDevice.current.identifierForVendor!.uuidString
            return ["device_id" : uuid, "registration_id" : token]
        case .updatePushToken(let token, _):
            return ["token" : token, "os" : "ios"]
        case .changePsw(let params):
            return params as Parameters
        default: return nil
        }
    }
    
    override open var encoding: ParameterEncoding? {
        switch endpoint {
        case .registerUser(_):
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }

}
