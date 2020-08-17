//
//  ContentManager.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 26/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Alamofire

typealias ContentsResponseBlock = (_ contents: [Content]?, _ error: Error?) -> ()
typealias ShareContentResponseBlock = (_ success: Bool, _ error: Error?) -> ()
typealias ContentInboxResponseBlock = (_ inbox: [Inbox]?, _ error: Error?) -> ()

typealias ContentConsumeDataResponseBlock = (_ contentConsumeData: ContentConsumeData?, _ error: Error?) -> ()

open class ContentManager: BaseManager {
    
    open class var sharedInstance: ContentManager {
        struct Singleton {
            static let instance = ContentManager()
        }
        return Singleton.instance
    }
    
    var result = [[String:Any]]()
    
    // MARK: - Methods
    
    //TODO: Handle 404 by showing text on screen that no content is available
    
    
    func consumeAmbassadorshipContent(_ contentId: Int, completion: @escaping ContentConsumeDataResponseBlock) {
        let router = ContentRouter(endpoint: .consumeAmbassadorshipContent(contentId: contentId))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                let responseDict = dict as! [String:Any]
                let contentConsumeData = ContentConsumeData(dictionary: responseDict)
                completion(contentConsumeData, nil)
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    
    
    func shareContent(_ contentId: Int, targetUserId: Int, completion: @escaping ShareContentResponseBlock) {
        let router = ContentRouter(endpoint: .shareAmbassadorshipContent(contentId: contentId, targetUserId: targetUserId))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(_):
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        })
    }
    
    func getInbox(_ completion: @escaping ContentInboxResponseBlock) {
        let router = ContentRouter(endpoint: .getContentInbox)
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                let responseDict = dict as! [String:Any]
                let responseDictData = responseDict["data"] as! Array<[String:Any]>
                let inbox = responseDictData.map({ Inbox(dict: $0) })
                completion(inbox, nil)
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    //"https://ilistambassador.s3.amazonaws.com:443/dev/savedframe/WELCOME.png"
    //"https://ilistambassador.s3.amazonaws.com:443/dev/savedframe/sun.png"
    //"frame_url" 
    
    func getContentForId(_ id: Int, page: Int = 1, completion: @escaping ContentsResponseBlock) {
        let router = ContentRouter(endpoint: .getContentForAmbassadorship(id: id, page: page, pageSize: 20))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                if let responseDict = dict as? Array<[String:Any]> {
                    let contents = responseDict.map({ Content(dictionary: $0) }).sorted(by: { $0.order < $1.order })
                    completion(contents, nil)
                } else {
                    print("Failed to get contents")
                }
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    func getSharedContent(_ contentId: Int, completion: @escaping ContentsResponseBlock) {
        let router = ContentRouter(endpoint: .getSharedContent(contentId: contentId))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                if let responseDict = dict as? Array<[String:Any]> {
                    let contents = responseDict.map({ Content(dictionary: $0) }).sorted(by: { $0.order < $1.order })
                    print("Getting shared contents succeeded in not crashing")
                    completion(contents, nil)
                } else {
                    print("Failed to get shared contents")
                }

            case .failure(let error):
                completion(nil, error)
            }
        })
    }
    
    func createOutboundLink(_ contentId: Int, completion: @escaping DictionaryResponseBlock) {
        let router = ContentRouter(endpoint: .createOutboundLink(contentId: contentId))
        performRequest(withRouter: router, { (response: DataResponse<Any>) in
            switch response.result {
            case .success(let dict):
                let responseDict = dict as! [String:Any]
                completion(responseDict, nil)
            case .failure(let error):
                completion(nil, error)
            }
        })
    }
}
