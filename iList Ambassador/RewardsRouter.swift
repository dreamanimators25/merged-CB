//
//  RewardsRouter.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-07-24.
//  Copyright © 2017 iList AB. All rights reserved.
//

import Foundation
import Alamofire

public enum RewardEndpoint {
    case getRewardsForUser(id: Int)
    case getSingleRewardWithId(id: Int, rewardId: Int)
    case getBadges(id: Int)
    case getUserScore(id: Int)
    case getLevelBadges(id: Int)
    case getInfluencerBadges(id: Int)
    case useReward(id: Int)
}

open class RewardRouter: BaseRouter {
    
    var endpoint: RewardEndpoint
    
    public init(endpoint: RewardEndpoint) {
        self.endpoint = endpoint
    }
    
    override open var method: HTTPMethod {
        switch endpoint {
        case .getRewardsForUser: return .get
        case .getSingleRewardWithId: return .get
        case .getBadges: return .get
        case .getUserScore: return .get
        case .getLevelBadges: return .get
        case .getInfluencerBadges: return .get
        case .useReward: return .patch
        }
    }
    
    override open var path: String {
        switch endpoint {
        case .getRewardsForUser(let id): return "user-rewards/\(id)/"
        case .getSingleRewardWithId(let id, let rewardId): return "user-rewards/\(id)/rewards/\(rewardId)/"
        case .getBadges(let id): return "user-badges/\(id)/"
        case .getUserScore(let id): return "user-scores/\(id)/"
        case .getLevelBadges(let id): return "user-level/\(id)/"
        case .getInfluencerBadges(let id): return "user-influencer/\(id)/"
        case .useReward(let id): return "use-reward/"
        }
    }
    
    override open var parameters: Parameters? {
        
        switch endpoint {
        case .useReward(let id):
            return ["reward_id" : id]
        default: return nil
        }
 
    }
    
    override open var encoding: ParameterEncoding? {
        switch endpoint {
        case .useReward(_):
            return URLEncoding.httpBody
        default: return URLEncoding.default
        }
    }
}
