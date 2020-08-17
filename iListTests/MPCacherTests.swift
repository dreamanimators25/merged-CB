//
//  MPCacherTests.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-07-25.
//  Copyright © 2016 iList AB. All rights reserved.
//

import XCTest
import UIKit
import AVFoundation

class MPCacherTests: XCTestCase {
    let iterations = 1000
    let numberOfPlayers = 5
    
    
    override func setUp() {
        super.setUp()
        let item = AVPlayerItem(URL: NSURL(string: "https://ilistambassador.s3.amazonaws.com/content/backgrounds/Clean_Bandit_-__Tears_ft._Louisa_Johnson_Official_Video.mp4")!)
        let player = AVPlayer(playerItem:item)
        for i in 0..<numberOfPlayers {
            MPCacher.sharedInstance.setObjectForKey(player, key: "test\(i)")
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCacheDynamicSetAndRemove() {
        for i in 0..<iterations {
            let obj = MPCacher.sharedInstance.getObjectForKey("test\(i%numberOfPlayers)")
            XCTAssertNotNil(obj)
        }
        XCTAssertEqual(MPCacher.sharedInstance.keyMap.count, numberOfPlayers)
        XCTAssertEqual(MPCacher.sharedInstance.cacheFIFO.count, iterations)
        
        MPCacher.sharedInstance.removeLeastRecentUsed()
        XCTAssertEqual(MPCacher.sharedInstance.keyMap.values.count, numberOfPlayers-1)
        XCTAssertNotEqual(MPCacher.sharedInstance.cacheFIFO.count, iterations)
    }
}
