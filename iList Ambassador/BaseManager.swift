//
//  BaseManager2.swift
//  iList Ambassador
//
//  Created by External Three. Consultant on 16/11/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Alamofire

typealias DictionaryResponseBlock = (_ response: [String:Any]?, _ error: Error?) -> ()

open class BaseManager {
    
    lazy var sessionManager: SessionManager = {
        let sessionManager = SessionManager()
        sessionManager.adapter = OAuth2Handler.sharedInstance
        sessionManager.retrier = OAuth2Handler.sharedInstance
        return sessionManager
    }()
    
    static var credentials: iListOAuthClientCredentials{
        return iListOAuthClientCredentials()
    }
    
    static var baseUrlString: String {
        if let dict = Bundle.main.object(forInfoDictionaryKey: "iListAPI") as? [String:Any], let baseUrl = dict["API_URL"] as? String {
            return baseUrl
        }
        fatalError("[\(Mirror(reflecting: self).description) - \( #function ))] API url not found in .plist")
    }
    
    var hasAccessToken: Bool {
        return OAuth2Handler.hasAccessToken
    }
    
    // MARK: - Authentication
    
    func performRequest(withRouter router: BaseRouter, _ completionHandler: @escaping ((DataResponse<Any>) -> Void)) {
        print("PERFORMREQUEST")
        
        //Sameer 11/6/2020
        //to check token expire or not , if expire the refresh token and success call further api, and if not expire then direct call api
        
        let tokenTime = CustomUserDefault.getTokenTime() ?? 0.0
        let nowTime = Date().timeIntervalSince1970
        let currentTime = Double(nowTime)
        print(tokenTime,nowTime,currentTime)
        
        if tokenTime < currentTime {
            //Token Expired
            
            OAuth2Handler.sharedInstance.refreshExpiredToken { (bool, acc_token, ref_token) in
                
                //if bool {
                    OAuth2Handler.sharedInstance.update(accessToken: acc_token ?? "", refreshToken: ref_token ?? "")
                    
                    do {
                        let request = try router.asURLRequest()
                        print("request = \(request)")
                        
                        self.sessionManager.request(request)
                            .responseJSON { (response: DataResponse<Any>) in
                                //#if DEBUG
                            
                            switch response.result {
                            case .success(let dict):
                            
                                print("SUCCESS: \(String(describing: request.url?.absoluteString)): \(JSON_OLD.prettyJsonString(value: dict)), code = \( response.response?.statusCode ?? 0)")
                            case .failure(let error):
                                if let url = request.url?.absoluteString {
                                    print("ERROR \(url): \( error.localizedDescription )")
                                }
                            }
                                //#endif
                            completionHandler(response)
                        }
                    } catch {
                        debugPrint("error: \( error.localizedDescription )")
                        fatalError("Unable to get url request from router")
                    }
                    
                //}else {
                    //print("Do Nothing!")
                //}
                
            }
            
        }else {
            //Token Doesn't Expired
            do {
                let request = try router.asURLRequest()
                print("request = \(request)")
                sessionManager.request(request)
                    .responseJSON { (response: DataResponse<Any>) in
                        //#if DEBUG
                    
                    switch response.result {
                    case .success(let dict):
                    
                        print("SUCCESS: \(String(describing: request.url?.absoluteString)): \(JSON_OLD.prettyJsonString(value: dict)), code = \( response.response?.statusCode ?? 0)")
                    case .failure(let error):
                        if let url = request.url?.absoluteString {
                            print("ERROR \(url): \( error.localizedDescription )")
                        }
                    }
                        //#endif
                    completionHandler(response)
                }
            } catch {
                debugPrint("error: \( error.localizedDescription )")
                fatalError("Unable to get url request from router")
            }
            
        }
        
        /* Clien't Code commented by Sameer on 11/6/2020
        do {
            let request = try router.asURLRequest()
            print("request = \(request)")
            sessionManager.request(request)
                .responseJSON { (response: DataResponse<Any>) in
                    //#if DEBUG
                
                switch response.result {
                case .success(let dict):
                
                    print("SUCCESS: \(String(describing: request.url?.absoluteString)): \(JSON_OLD.prettyJsonString(value: dict)), code = \( response.response?.statusCode)")
                case .failure(let error):
                    if let url = request.url?.absoluteString {
                        print("ERROR \(url): \( error.localizedDescription )")
                    }
                }
                    //#endif
                completionHandler(response)
            }
        } catch {
            debugPrint("error: \( error.localizedDescription )")
            fatalError("Unable to get url request from router")
        }*/
    }
    
    func performRequest1(withRouter router: BaseRouter, _ completionHandler: @escaping ((DataResponse<Any>) -> Void)) {
        print("PERFORMREQUEST")
        
        do {
            let request = try router.asURLRequest()
            print("request = \(request)")
            sessionManager.request(request)
                .responseJSON { (response: DataResponse<Any>) in
                    //#if DEBUG
                
                switch response.result {
                case .success(let dict):
                
                    print("SUCCESS: \(String(describing: request.url?.absoluteString)): \(JSON_OLD.prettyJsonString(value: dict)), code = \( response.response?.statusCode)")
                case .failure(let error):
                    if let url = request.url?.absoluteString {
                        print("ERROR \(url): \( error.localizedDescription )")
                    }
                }
                    //#endif
                completionHandler(response)
            }
        } catch {
            debugPrint("error: \( error.localizedDescription )")
            fatalError("Unable to get url request from router")
        }
    }
    
    //S
    func performRequestWithAuth(withRouter router: BaseRouter, _ completionHandler: @escaping ((DataResponse<Any>) -> Void)) {
        print("PERFORMREQUEST")
        
        var request: URLRequest?
        
        do {
            request = try router.asURLRequest()
            //print("request = \(request)")
            request = try OAuth2Handler.sharedInstance.adapt(request!)
            //print("request = \(request)")
            
            guard let authenticatedRequest = request else {
                //completionHandler(nil)
                return
            }
            
            sessionManager.request(authenticatedRequest)
                .responseJSON { (response: DataResponse<Any>) in
                    //#if DEBUG
                    
                    switch response.result {
                    case .success(let dict):
                        
                        print("SUCCESS: \(String(describing: request?.url?.absoluteString)): \(JSON_OLD.prettyJsonString(value: dict)), code = \(String(describing:  response.response?.statusCode))")
                    case .failure(let error):
                        if let url = request?.url?.absoluteString {
                            print("ERROR \(url): \( error.localizedDescription )")
                        }
                    }
                    //#endif
                    completionHandler(response)
            }
        } catch {
            debugPrint("error: \( error.localizedDescription )")
            fatalError("Unable to get url request from router")
        }
    }
    
}
