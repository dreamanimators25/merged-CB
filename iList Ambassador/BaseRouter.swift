//
//  BaseRouter.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 26/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Alamofire

protocol APIConfiguration {
    var method: HTTPMethod { get }
    var encoding: Alamofire.ParameterEncoding? { get }
    var path: String { get }
    var parameters: Parameters? { get }
    static var baseUrl: String { get }
}

open class BaseRouter: URLRequestConvertible, APIConfiguration {

    fileprivate static let plistName = "iListAPI"
    
    public init() {
        
    }
    
    open var method: HTTPMethod {
        fatalError("[\(Mirror(reflecting: self).description) - \( #function ))] Must be overridden in subclass")
    }
    
    open var encoding: ParameterEncoding? {
        fatalError("[\(Mirror(reflecting: self).description) - \( #function ))] Must be overridden in subclass")
    }
    
    open var path: String {
        fatalError("[\(Mirror(reflecting: self).description) - \( #function ))] Must be overridden in subclass")
    }
    
    open var parameters: Parameters? {
        fatalError("[\(Mirror(reflecting: self).description) - \( #function ))] Must be overridden in subclass")
    }
    
    public static var baseUrl: String {
        if let dict = Bundle.main.object(forInfoDictionaryKey: "iListAPI") as? [String:Any], let baseUrl = dict["API_URL"] as? String {
            return baseUrl
        }
        fatalError("[\(Mirror(reflecting: self).description) - \( #function ))] API url not found in .plist")
    }
    
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    ///
    /// - returns: A URL request.
    public func asURLRequest() throws -> URLRequest {
        let baseURL = URL(string: BaseRouter.baseUrl)!
        var mutableURLRequest = URLRequest(url: baseURL.appendingPathComponent(path))
        mutableURLRequest.httpMethod = method.rawValue
        
        if let encoding = encoding {
            do {
                let x = try encoding.encode(mutableURLRequest, with: parameters)
                print("BODY: \(x.httpBody?.description)")
                return x
            } catch {
                debugPrint("error: \(error)")
            }
        }
        print(mutableURLRequest.httpBody!)
        return mutableURLRequest
    }
    
}
