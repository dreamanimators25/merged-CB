//
//  Player.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-07-22.
//  Copyright © 2016 iList AB. All rights reserved.
//

import AVFoundation

protocol PlayerDelegate {
    func playbackLikelyToKeepUp()
}

var blockPlayBack : (() -> (Void))?

class Player: AVPlayer {
    var delegate: PlayerDelegate?
    
    override init(url: URL) {
        super.init(url: url)
        self.setup()
    }
    
    override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
        self.setup()
    }
    
    override init() {
        super.init()
        self.setup()
    }
    
    func setup() {
        isMuted = true
        if let currentItem = currentItem {
            NotificationCenter.default.addObserver(self, selector: #selector(restartFromBeginning), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: currentItem)
            currentItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions(), context: nil)
            currentItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
        }
    }
    
    deinit {
        if let currentItem = currentItem {
            currentItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            currentItem.removeObserver(self, forKeyPath: "status")
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = keyPath {
            if key == "playbackLikelyToKeepUp" || key == "status" {
                if let currentItem = currentItem {
                    let duration = currentItem.duration
                    let currentTime = currentItem.currentTime()
                    if duration == currentTime {
                        restartFromBeginning()
                    } else {
                        testKeepUp()
                    }
                }
            }
        }
    }
    
    @objc func restartFromBeginning()  {
        let seekTime: CMTime = CMTimeMake(value: 0, timescale: 1)
        seek(to: seekTime)
        testKeepUp()
    }

    
    func testKeepUp() {
        if let currentItem = currentItem, currentItem.isPlaybackLikelyToKeepUp && currentItem.status == .readyToPlay {
            
            //if let block = blockPlayBack {
                //block()
            //}
            
            delegate?.playbackLikelyToKeepUp()
        }
    }
}

