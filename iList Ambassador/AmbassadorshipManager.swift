//
//  AmbassadorshipManager.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 22/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Alamofire

typealias AmbassadorshipEmptyResponseBlock = (_ error: Error?) -> ()
typealias AmbassadorshipResponseBlock = (_ ambassadorship: Ambassadorship?, _ error: Error?) -> ()
typealias AmbassadorshipsResponseBlock = (_ ambassadorships: [Ambassadorship]?, _ error: Error?) -> ()

typealias AmbassadorshipsResponseGetBlock = (_ ambassadorships: Ambassadorship?, _ error: Error?, _ code: Int) -> ()

open class AmbassadorshipManager: BaseManager {
    
    open class var sharedInstance: AmbassadorshipManager {
        struct Singleton {
            static let instance = AmbassadorshipManager()
        }
        return Singleton.instance
    }
    
    // MARK: - Methods
    func getAmbassadorshipsForUser(_ userId: Int, page: Int = 1, pageSize: Int = 20, completion: @escaping AmbassadorshipsResponseBlock) {
        let router = AmbassadorshipRouter(endpoint: .getAmbassadorshipsForUser(id: userId))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                let responseDict = dict as! [String:Any]
                let responseArray = responseDict["data"] as? Array<[String:Any]> ?? [[:]]
                
                let ambassadorships = responseArray.map({ Ambassadorship(dictionary: $0) })
                completion(ambassadorships, nil)
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    func getAmbassadorshipsForAnyUser(_ userId: Int, page: Int = 1, pageSize: Int = 20, completion: @escaping AmbassadorshipsResponseBlock) {
        let router = AmbassadorshipRouter(endpoint: .getAmbassadorshipsForAnyUser(id: userId))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                let responseDict = dict as! [String:Any]
                let responseArray = responseDict["data"] as! Array<[String:Any]>
                
                let ambassadorships = responseArray.map({ Ambassadorship(dictionary: $0) })
                completion(ambassadorships, nil)
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    /*
    func getAmbassadorshipsForUser(_ userId: Int, page: Int = 1, pageSize: Int = 20, completion: @escaping AmbassadorshipsResponseBlock) {
        let router = AmbassadorshipRouter(endpoint: .getAmbassadorshipsForUser(id: userId))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                let responseDict = dict as! [String:Any]
                let responseArray = responseDict["data"] as! Array<[String:Any]>
                let ambassadorships = responseArray.map({ Ambassadorship(dictionary: $0) })
                completion(ambassadorships, nil)
            case .failure(let error):
                completion(nil, error)
            }
        })
    }*/
    
    func requestAmbassadorhipWithCode(_ code:String,completion: @escaping AmbassadorshipsResponseGetBlock) {
        let router = AmbassadorshipRouter(endpoint: .sendAmbassadorshipRequestWithCode(code: code))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            let code = response.response == nil ? 0 : response.response!.statusCode
            switch response.result {
            case .success(let dict):
                let responseDict = dict as! [String:Any]
                if responseDict.count > 0 {
                    let ambassadorship = Ambassadorship(dictionary: responseDict)
                    completion(ambassadorship, nil, code)
                }
                else {
                    completion(nil, nil, code)
                }
            case .failure(let error):
                completion(nil, error, code)
            }
        })
    }
    
    func revokeAmbassadorship(_ ambassadorship: Ambassadorship, completion: @escaping AmbassadorshipEmptyResponseBlock) {
        let router = AmbassadorshipRouter(endpoint: .updateAmbassadorshipStatus(ambassadorship: ambassadorship, status: .rejected))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
    }
}
