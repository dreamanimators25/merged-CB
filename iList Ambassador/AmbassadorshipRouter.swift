//
//  AmbassadorshipRouter.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 26/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Alamofire

public enum AmbassadorshipEndpoint {
    case getAmbassadorship(id: Int)
    case getAmbassadorshipsForUser(id: Int)
    case getAmbassadorshipsForAnyUser(id: Int)
    case sendAmbassadorshipRequestWithCode(code: String)
    case updateAmbassadorshipStatus(ambassadorship: Ambassadorship, status: AmbassadorshipStatus)
}

open class AmbassadorshipRouter: BaseRouter {
    
    var endpoint: AmbassadorshipEndpoint
    
    public init(endpoint: AmbassadorshipEndpoint) {
        self.endpoint = endpoint
    }
    
    override open var method: HTTPMethod {
        switch endpoint {
        case .getAmbassadorship: return .get
        case .getAmbassadorshipsForUser: return .get
        case .getAmbassadorshipsForAnyUser: return .get
        case .sendAmbassadorshipRequestWithCode: return .post
        case .updateAmbassadorshipStatus: return .delete
        }
    }
    
    override open var path: String {
        switch endpoint {
        case .getAmbassadorship(let id): return "ambassadorships/\(id)/"
        case .getAmbassadorshipsForUser(_): return "ambassadorships/"
        case .getAmbassadorshipsForAnyUser(let id): return "list-ambassadorships/\(id)/"
        case .sendAmbassadorshipRequestWithCode(_): return "ambassadorship-requests/"
        case .updateAmbassadorshipStatus(let ambassadorship, _): return "ambassadorships/\(ambassadorship.id)/"
        }
    }
    
    override open var parameters: Parameters? {
        switch endpoint {
        case .getAmbassadorshipsForUser(let id):
            return ["user_id" : id]
        case .sendAmbassadorshipRequestWithCode(let code):
            return ["code" : code]
        case .updateAmbassadorshipStatus(_, let status):
            return ["status" : status.rawValue]
        default:
            return nil
        }
    }
    
    override open var encoding: ParameterEncoding? {
        switch endpoint {
        case .getAmbassadorship: return URLEncoding.default
        case .getAmbassadorshipsForUser: return URLEncoding.default
        case .getAmbassadorshipsForAnyUser: return URLEncoding.default
        case .sendAmbassadorshipRequestWithCode: return URLEncoding.default
        case .updateAmbassadorshipStatus: return URLEncoding.default
        }
    }
    
}
