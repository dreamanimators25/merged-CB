//
//  GroupList.swift
//
//  Created by Sameer's MacBook Pro on 30/11/19
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class GroupList: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let brandId = "brand_id"
    static let groupName = "group_name"
    static let ambassadorshipsId = "ambassadorships_id"
    static let groupId = "group_id"
  }

  // MARK: Properties
  public var brandId: Int?
  public var groupName: String?
  public var ambassadorshipsId: Int16?
  public var groupId: Int?

  // MARK: SwiftyJSON Initializers
  /// Initiates the instance based on the object.
  ///
  /// - parameter object: The object of either Dictionary or Array kind that was passed.
  /// - returns: An initialized instance of the class.
  public convenience init(object: Any) {
    self.init(json: JSON(object))
  }

  /// Initiates the instance based on the JSON that was passed.
  ///
  /// - parameter json: JSON object from SwiftyJSON.
  public required init(json: JSON) {
    brandId = json[SerializationKeys.brandId].int
    groupName = json[SerializationKeys.groupName].string
    ambassadorshipsId = json[SerializationKeys.ambassadorshipsId].int16
    groupId = json[SerializationKeys.groupId].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = brandId { dictionary[SerializationKeys.brandId] = value }
    if let value = groupName { dictionary[SerializationKeys.groupName] = value }
    if let value = ambassadorshipsId { dictionary[SerializationKeys.ambassadorshipsId] = value }
    if let value = groupId { dictionary[SerializationKeys.groupId] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.brandId = aDecoder.decodeObject(forKey: SerializationKeys.brandId) as? Int
    self.groupName = aDecoder.decodeObject(forKey: SerializationKeys.groupName) as? String
    self.ambassadorshipsId = aDecoder.decodeObject(forKey: SerializationKeys.ambassadorshipsId) as? Int16
    self.groupId = aDecoder.decodeObject(forKey: SerializationKeys.groupId) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(brandId, forKey: SerializationKeys.brandId)
    aCoder.encode(groupName, forKey: SerializationKeys.groupName)
    aCoder.encode(ambassadorshipsId, forKey: SerializationKeys.ambassadorshipsId)
    aCoder.encode(groupId, forKey: SerializationKeys.groupId)
  }

}
