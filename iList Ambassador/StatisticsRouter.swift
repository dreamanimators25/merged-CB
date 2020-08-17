//
//  StatisticsRouter.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 31/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Alamofire

public enum StatisticsEndpoint {
    case sendAmbassadorStatistic(id: Int, stats: [[String: AnyObject]])
}

open class StatisticsRouter: BaseRouter {
    
    var endpoint: StatisticsEndpoint
    
    public init(endpoint: StatisticsEndpoint) {
        self.endpoint = endpoint
    }
    
    override open var method: HTTPMethod {
        switch endpoint {
        case .sendAmbassadorStatistic: return .post
        }
    }
    
    override open var path: String {
        switch endpoint {
        case .sendAmbassadorStatistic(let id, _): return "ambassadorships/\(id)/content-viewed-statistics/"
        }
    }
    
    override open var parameters: Parameters? {
        switch endpoint {
        case .sendAmbassadorStatistic(_, let stats):
            return ["contents_visited" : stats as AnyObject]
        }
    }
    
    override open var encoding: Alamofire.ParameterEncoding? {
        switch endpoint {
        default: return JSONEncoding.default
        }
    }
    
}



//// MARK: - Statistics
//
//func statistics_setReceivedOfferUsed(offerID: Int, forUserWithID userID: Int, onCompletion: CompletionBlock, onFailure: FailureBlock) {
//    let params: Dictionary<String,AnyObject> = [
//        "user" : userID,
//        "received_offer" : offerID
//    ]
//    
//    let endpoint = String(format: "statistics/received-offer-use")
//    
//    self.sendRequestToEndpoint(endpoint, requestMethod: .POST, params: params, isStatistics: true, completionBlock: onCompletion, failureBlock: onFailure)
//}
//
//func statistics_setReceivedOfferLinkClicked(offerID: Int, forUserWithID userID: Int, onCompletion: CompletionBlock, onFailure: FailureBlock) {
//    let params: Dictionary<String,AnyObject> = [
//        "user" : userID,
//        "received_offer" : offerID
//    ]
//    
//    let endpoint = String(format: "statistics/received-offer-link-clicked")
//    
//    self.sendRequestToEndpoint(endpoint, requestMethod: .POST, params: params, isStatistics: true, completionBlock: onCompletion, failureBlock: onFailure)
//}
//
//func statistics_setReceivedOfferView(offerID: Int, forUserWithID userID: Int, onCompletion: CompletionBlock, onFailure: FailureBlock) {
//    let params: Dictionary<String,AnyObject> = [
//        "user" : userID,
//        "received_offer" : offerID
//    ]
//    
//    let endpoint = String(format: "statistics/received-offer-view")
//    
//    self.sendRequestToEndpoint(endpoint, requestMethod: .POST, params: params, isStatistics: true, completionBlock: onCompletion, failureBlock: onFailure)
//}
//
//func statistics_setAmbassadorshipOfferView(offerID: Int, ambassadorshipID: Int, onCompletion: CompletionBlock, onFailure: FailureBlock) {
//    let params: Dictionary<String,AnyObject> = [
//        "ambassadorship" : ambassadorshipID,
//        "ambassadorship_offer" : offerID
//    ]
//    
//    let endpoint = String(format: "statistics/ambassadorship-offer-view")
//    
//    self.sendRequestToEndpoint(endpoint, requestMethod: .POST, params: params, isStatistics: true, completionBlock: onCompletion, failureBlock: onFailure)
//}
//
//func statistics_setAmbassadorshipOfferShare(offerID: Int, ambassadorshipID: Int, toUserID: Int, userID: Int, onCompletion: CompletionBlock, onFailure: FailureBlock) {
//    let params: Dictionary<String,AnyObject> = [
//        "ambassadorship_offer" : offerID,
//        "ambassadorship" : ambassadorshipID,
//        "shared_by" : userID,
//        "shared_to" : toUserID
//    ]
//    
//    let endpoint = String(format: "statistics/ambassadorship-offer-share")
//    
//    self.sendRequestToEndpoint(endpoint, requestMethod: .POST, params: params, isStatistics: true, completionBlock: onCompletion, failureBlock: onFailure)
//}
