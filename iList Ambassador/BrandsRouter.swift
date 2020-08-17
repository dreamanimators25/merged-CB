//
//  BrandsRouter.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 09/04/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation
import Alamofire

public enum BrandsEndpoint {
    case getBrand(id: Int)
    case getBrands(Void)
}

open class BrandsRouter: BaseRouter {
    
    var endpoint: BrandsEndpoint
    
    public init(endpoint: BrandsEndpoint) {
        self.endpoint = endpoint
    }
    
    override open var method: HTTPMethod {
        switch endpoint {
        case .getBrand: return .get
        case .getBrands: return .get
        }
    }
    
    override open var path: String {
        switch endpoint {
        case .getBrand(let id): return "brands/\( id )"
        case .getBrands(): return "brands/"
        }
    }
    
    override open var parameters: Parameters? {
        return nil
//        switch endpoint {
//        case .GetBrands(let query, let page):
//            return ["query" : query, "page" : page]
//        default: return nil
//        }
    }
    
    override open var encoding: ParameterEncoding? {
        return JSONEncoding.default
//        switch endpoint {
//        case .GetBrand(let id): return .JSON
//        case .GetBrands(): return .JSON
//        }
    }
    
    open var protected: Bool {
        return true
    }
    
}
