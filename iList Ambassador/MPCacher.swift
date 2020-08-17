//
//  MPCacher.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-07-25.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit

class MPCacher: NSCache<AnyObject, AnyObject> {
    
    static let sharedInstance = MPCacher()
    
//    let diskQueue: dispatch_queue_t = dispatch_queue_create("com.iList_Ambassador.diskQueue", DISPATCH_QUEUE_SERIAL)

    let cacheName = "iList_Ambassador.mp.cache"
    
    fileprivate var observer: NSObjectProtocol!
    
    // [timestamp]
    var cacheFIFO = [String]()
    
    // [key : timestamp]
    var keyMap = [String: String]()
    
    fileprivate override init() {
        super.init()
        name = cacheName
        
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: nil) { [unowned self] notification in
            self.removeLeastRecentUsed()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
    
    // MARK: - Caching
    
    /**
     *  Cache AnyObject
     *  Returns a cached object immediately or uses the cacheBlock to capture the new object and then returns the new cached object.
     */
    fileprivate func getOrSetObjectForKey(_ object: AnyObject?, key: String)-> CacheObject? {
        let timestamp = "\(currentTimeMillis())".replacingOccurrences(of: " ", with: "")
        var cachedObject: CacheObject?
        if let cacheO = self.object(forKey: key as AnyObject) as? CacheObject {
            let oldTimestamp = cacheO.timestamp
            cacheO.timestamp = timestamp
            keyMap.removeValue(forKey: oldTimestamp)
            keyMap[timestamp] = key
            cacheFIFO.append(timestamp)
            cachedObject = cacheO
        } else if let object = object {
            let newObject = CacheObject(object: object, timestamp: timestamp)
            setObject(newObject, forKey: key as AnyObject)
            keyMap[timestamp] = key
        }
        return cachedObject
    }
    
    /**
     *  Removes Least Recent Used Objects
     */
    func removeLeastRecentUsed() {
        var didRemove = false
        while !didRemove && cacheFIFO.count > 0 && keyMap.count > 0 {
            if let first = cacheFIFO.first, let key = keyMap[first] {
                removeObject(forKey: key as AnyObject)
                keyMap.removeValue(forKey: first)
                didRemove = true
            }
            cacheFIFO.removeFirst()
        }
    }
    
    func getObjectForKey(_ key: String) -> AnyObject? {
        let object = getOrSetObjectForKey(nil, key: key)
        return object?.object
    }
    
    func setObjectForKey(_ object: AnyObject, key: String) {
        let _ = getOrSetObjectForKey(object, key: key)
    }
    
    func currentTimeMillis() -> Int64 {
        let nowDouble = Date().timeIntervalSince1970
        return Int64(nowDouble*100000)
    }
}

class CacheObject: NSObject {
    var object: AnyObject
    var timestamp: String
    
    init(object: AnyObject, timestamp: String) {
        self.object = object
        self.timestamp = timestamp
    }
}
