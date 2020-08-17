//
//  UserRouter.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 26/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Alamofire

enum ContentEndpoint {
    case GetContentForBrand(brand: Brand, page: Int)
    case GetContent(id: Int)
//    case UpdateContent(content: Content)
//    case DeleteContent(content: Content)
}

class ContentRouter: BaseRouter {
    
    var endpoint: ContentEndpoint
    
    init(endpoint: ContentEndpoint) {
        self.endpoint = endpoint
    }
    
    override var method: Alamofire.Method {
        switch endpoint {
        case .GetContentForBrand: return .GET
        case .GetContent: return .GET
//        case .UpdateContent: return .PUT
//        case .DeleteContent: return .DELETE
        }
    }
    
    override var path: String {
        switch endpoint {
        case .GetContentForBrand(let brand, _): return "/brands/\( brand.id )/content"
        case .GetContent(let id): return "/content/\(id)"
//        case .UpdateContent(let content): return "/content/\(content.id)"
//        case .DeleteContent(let content): return "/content/\(content.id)"
        }
    }
    
    override var parameters: [String : AnyObject]? {
        switch endpoint {
        case .GetContentForBrand(let brand, let page):
            return ["brand" : brand.id, "page" : page]
//        case .UpdateContent(let content):
//            return content.toDictionary()
        default: return nil
        }
    }
    
    override var encoding: Alamofire.ParameterEncoding? {
        switch endpoint {
        case .GetContentForBrand: return .URL
        case .GetContent: return .URL
//        default: return .JSON
        }
    }
    
}