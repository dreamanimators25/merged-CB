//
//  RewardManager.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-08-15.
//  Copyright © 2017 iList AB. All rights reserved.
//

import Foundation
import Alamofire


typealias RewardsResponseBlock = (_ contents: [RewardList]?, _ error: Error?, _ success: Bool) -> ()
typealias FullRewardsResponseBlock = (_ contents: [Reward]?, _ error: Error?, _ success: Bool) -> ()
typealias BadgeResponseBlock = (_ badges: [Badge]?, _ error: Error?, _ success: Bool) -> ()
typealias UserScoreResponseBlock = (_ score: [String:Any]?, _ error: Error?, _ success: Bool) -> ()
typealias LevelBadgeResponseBlock = (_ level: [Bool]?, _ error: Error?, _ success: Bool) -> ()
typealias InfluencerBadgeResponseBlock = (_ influencer: [Bool]?, _ error: Error?, _ success: Bool) -> ()
typealias useRewardResponseBlock = (_ responseCode: Int?) -> ()
open class RewardManager: BaseManager {
    
    open class var sharedInstance: RewardManager {
        struct Singleton {
            static let instance = RewardManager()
        }
        return Singleton.instance
    }
    
    var result = [[String:Any]]()
    private var levelArray = [[String:Any]]()
    
    // MARK: - Methods
    func useReward(_ id: Int, completion: @escaping useRewardResponseBlock) {
        let router = RewardRouter(endpoint: .useReward(id: id))
        print("Performing request for use reward")
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            completion(response.response?.statusCode)
        })
    }

    
    
    func getFullReward(_ id: Int, rewardId: Int, completion: @escaping FullRewardsResponseBlock) {
        let router = RewardRouter(endpoint: .getSingleRewardWithId(id: id, rewardId: rewardId))
        print("Performing request for full reward")
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                if let responseDict = dict as? [String:Any] {
                    self.result.removeAll()
                    self.result.append(responseDict)
                    let rewards = self.result.map({ Reward(dictionary: $0) }).sorted(by: { ($0.id) < ($1.id) })
                    print("Performing request for full reward is finishing")
                    completion(rewards, nil, true)
                } else {
                    print(completion(nil, Error?.self as? Error, false))
                }
            case .failure(let error):
                completion(nil, error, false)
            }
        })
    }
    
    func getRewardsForId(_ id: Int, completion: @escaping RewardsResponseBlock) {
        let router = RewardRouter(endpoint: .getRewardsForUser(id: id))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                if let responseDict = dict as? Array<[String:Any]> {
                    let rewards = responseDict.map({ RewardList(json: $0) }).sorted(by: { ($0?.id)! < ($1?.id)! })
                    completion(rewards as? [RewardList], nil, true)
                } else {
                    print(completion(nil, Error?.self as? Error, false))
                }
            case .failure(let error):
                completion(nil, error, false)
            }
        })
    }
    
    func getUserScore(_ id: Int, completion: @escaping UserScoreResponseBlock) {
        let router = RewardRouter(endpoint: .getUserScore(id: id))
        performRequest(withRouter: router) { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                if let responseDict = dict as? [String:Any] {
                    completion(responseDict, nil, true)
                }else {
                    print(completion(nil, Error?.self as? Error, false))
                }
            case .failure(let error):
                completion(nil, error, false)
            }
        }
    }
    
    func getBadges(_ id: Int, completion: @escaping BadgeResponseBlock) {
        let router = RewardRouter(endpoint: .getBadges(id: id))
        performRequest(withRouter: router) { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                if let responseDict = dict as? Array<[String:Any]> {
                    let badges = responseDict.map( { Badge(json: $0) }).sorted(by: { ($0?.brandBadge.brand)! < ($1?.brandBadge.brand)! })
                    completion((badges as? [Badge])!, nil, true)
                }else {
                    print(completion(nil, Error?.self as? Error, false))
                }
            case .failure(let error):
                completion(nil, error, false)
            }
        }
    }
    
    func getLevelBadges(_ id: Int, completion: @escaping LevelBadgeResponseBlock) {
        let router = RewardRouter(endpoint: .getLevelBadges(id: id))
        performRequest(withRouter: router) { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                if let responseDict = dict as? [String:Any] {
                    var answer = [Bool]()
                    answer.append(responseDict["level1"] as! Bool)
                    answer.append(responseDict["level2"] as! Bool)
                    answer.append(responseDict["level3"] as! Bool)
                    answer.append(responseDict["level4"] as! Bool)
                    completion(answer, nil, true)

                }else {
                    print(completion(nil, Error?.self as? Error, false))
                }
            case .failure(let error):
                completion(nil, error, false)
            }
        }
    }
    
    func getInfluencerBadges(_ id: Int, completion: @escaping InfluencerBadgeResponseBlock) {
        let router = RewardRouter(endpoint: .getInfluencerBadges(id: id))
        performRequest(withRouter: router) { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                if let responseDict = dict as? [String:Any] {
                    var answer = [Bool]()
                    answer.append(responseDict["influencer1"] as! Bool)
                    answer.append(responseDict["influencer2"] as! Bool)
                    answer.append(responseDict["influencer3"] as! Bool)
                    answer.append(responseDict["influencer4"] as! Bool)
                    completion(answer, nil, true)

                }else {
                    print(completion(nil, Error?.self as? Error, false))
                }
            case .failure(let error):
                completion(nil, error, false)
            }
        }
    }
}
