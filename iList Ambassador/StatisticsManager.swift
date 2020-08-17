//
//  StatisticsManager.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-07-14.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Alamofire

class StatisticsManager: BaseManager {
    
    internal class var sharedInstance: StatisticsManager {
        struct Singleton {
            static let instance = StatisticsManager()
        }
        return Singleton.instance
    }
    
    func sendAmbassadorStatistics(_ stats: AmbassadorStatistic, completion: @escaping SuccessResponseBlock) {
        let router = StatisticsRouter(endpoint: .sendAmbassadorStatistic(id: stats.getId(), stats: stats.toDict())) //Sameer 15/6/2020
        //let router = StatisticsRouter(endpoint: .sendAmbassadorStatistic(id: stats.getId(), stats: [stats.toDict()]))
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
