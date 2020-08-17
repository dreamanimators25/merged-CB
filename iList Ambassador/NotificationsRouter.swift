//
//  NotificationsRouter.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 31/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Alamofire

public enum NotificationsEndpoint {
    case getNotificationsForUser(user: User)
}

open class NotificationsRouter: BaseRouter {
    
    var endpoint: NotificationsEndpoint
    
    public init(endpoint: NotificationsEndpoint) {
        self.endpoint = endpoint
    }
    
    override open var method: HTTPMethod {
        switch endpoint {
        case .getNotificationsForUser: return .get
        }
    }
    
    override open var path: String {
        switch endpoint {
        case .getNotificationsForUser(_): return "user-notifications/"
        }
    }
    
    override open var parameters: Parameters? {
        switch endpoint {
        case .getNotificationsForUser(let user):
            return ["user" : user.id as AnyObject]
        }
    }
    
    override open var encoding: ParameterEncoding? {
        switch endpoint {
        case .getNotificationsForUser: return URLEncoding.default
        }
    }
    
}
