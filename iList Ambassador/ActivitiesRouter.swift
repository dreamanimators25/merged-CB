//
//  ActivitiesRouter.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 02/05/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Alamofire

public enum ActivitiesEndpoint {
    case getActivitiesForUser(userId: Int)
}

open class ActivitiesRouter: BaseRouter {
    
    var endpoint: ActivitiesEndpoint
    
    public init(endpoint: ActivitiesEndpoint) {
        self.endpoint = endpoint
    }
    
    override open var method: HTTPMethod {
        switch endpoint {
        case .getActivitiesForUser(_): return .get
        }
    }
    
    override open var path: String {
        switch endpoint {
        case .getActivitiesForUser(let userId): return "users/\(userId)/activities/"
        }
    }
    
    override open var parameters: Parameters? {
        switch endpoint {
        case .getActivitiesForUser(_):
            return nil
        }
    }
    
    override open var encoding: ParameterEncoding? {
        switch endpoint {
        case .getActivitiesForUser: return URLEncoding.default
        }
    }
    
}
