//
//  ActivitiesManager.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 02/05/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Alamofire

typealias ActivityResponseBlock = (_ activity: Activity?, _ error: Error?) -> ()
typealias ActivitesResponseBlock = (_ activities: [Activity]?, _ error: Error?) -> ()

open class ActivitiesManager: BaseManager {
    
    open class var sharedInstance: ActivitiesManager {
        struct Singleton {
            static let instance = ActivitiesManager()
        }
        return Singleton.instance
    }
    
    // MARK: - Methods
    
    func getActivitiesForUser(_ user: User, page: Int = 1, pageSize: Int = 20, completion: @escaping ActivitesResponseBlock) {
        let router = ActivitiesRouter(endpoint: .getActivitiesForUser(userId: user.id))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                let responseDict = dict as! [String:Any]
                let responseArray = responseDict["data"] as! Array<[String:Any]>
                let activities = responseArray.map({ Activity(dictionary: $0) })
                completion(activities, nil)
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
}
