//
//  LoopingPlayer.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-03-28.
//  Copyright © 2016 capture. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

/*
class LoopingPlayer: AVPlayer {
    var shouldPlay = false
    override init(URL url: NSURL) {
        super.init(URL: url)
        self.commonInit()
    }
    override init(playerItem item: AVPlayerItem) {
        super.init(playerItem: item)
        self.commonInit()
    }
    override init() {
        super.init()
        self.commonInit()
    }
    
    func commonInit() {
        self.actionAtItemEnd = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(LoopingPlayer.restartVideoFromBeginning), name:AVPlayerItemDidPlayToEndTimeNotification, object:nil)
        self.muted = true
        //self.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
    }
    func restartVideoFromBeginning()  {
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        self.seekToTime(seekTime)
        self.play()
    }
    func deallocObservers() {
        //self.removeObserver(self, forKeyPath: "rate")
        NSNotificationCenter.defaultCenter().removeObserver(AVPlayerItemDidPlayToEndTimeNotification)
    }
    func isPlaying() -> Bool {
        return self.rate > 0
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let key = keyPath {
            if key == "rate" {
                if let item = self.currentItem {
                    if self.rate == 0 && CMTimeGetSeconds(item.duration) != CMTimeGetSeconds(item.currentTime()) && shouldPlay {
                        continuePlaying()
                    }
                }
            }
        }
    }
    var tryies = 0
    func continuePlaying() {
        if let item = self.currentItem {
            if item.playbackLikelyToKeepUp {
                self.play()
            } else {
                tryies += 1
                if tryies < 11 {
                    continuePlaying()
                } else {
                    self.play()
                }
            }
        }
    }
}
*/














