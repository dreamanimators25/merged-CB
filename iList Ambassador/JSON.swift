//
//  JSON.swift
//  iList Ambassador
//
//  Created by External Three. Consultant on 18/11/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import Foundation


class JSON_OLD {
    static func prettyJsonString(value: Any) -> String {
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted)
                return String(data: data, encoding: String.Encoding.utf8) ?? ""
            } catch {
                // Do nothing
            }
        }
        return value as? String ?? ""
    }
}
