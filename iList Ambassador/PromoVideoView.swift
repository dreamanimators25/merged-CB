//
//  PromoVideoView.swift
//  ProCamps
//
//  Created by Aleksandr Zhovtyi on 1/25/18.
//  Copyright © 2018 Aleksandr Zhovtyi. All rights reserved.
//

import UIKit
import AVFoundation

class PromoVideoView: UIView {

    fileprivate var url: URL?
    fileprivate var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    var observers = [Any]()

    //    MARK: - Intializations & overrids
    deinit {
        unregisterObservers()

        player?.pause()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil
        

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)//sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error.localizedDescription)
        }
        
        // Notify every 1 seconds
//        Mute.shared.checkInterval = 1.0
//
//        // Always notify on interval
//        Mute.shared.alwaysNotify = true
        
        
//        // Update label when notification received
//        Mute.shared.notify = { [weak self] m in
//            self?.player?.isMuted = m
//        }
    }

    //    MARK: - Utilities
    
    var videoURL: URL? {
        get { return self.url }
        set {
            if self.url != newValue {
                self.url = newValue
                self.loadVideo()
            }
        }
    }
    
    func play() {
        self.player?.play()
    }
    
    func pause() {
        self.player?.pause()
    }
    
    fileprivate func loadVideo() {
        guard let url = self.url else {
            return
        }

        //this line is important to prevent background music stop

        self.unregisterObservers()
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil


        /* Creates new layer an place it into the view */

//        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        
        
            

        player = AVPlayer(url: url)
        player?.isMuted = true// Mute.shared.isMute
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.backgroundColor = UIColor.clear.cgColor

        playerLayer?.frame = bounds


        playerLayer?.frame.size.width = self.bounds.width // Strange behavouir
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill

        playerLayer!.zPosition = -1

        layer.addSublayer(playerLayer!)
        layer.needsDisplayOnBoundsChange = true

        player?.seek(to: CMTime.zero)

        registerObservers()

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer?.frame = bounds
        playerLayer?.frame.size.width = self.bounds.width
    }

    //    MARK: - Observers
    private func registerObservers() {
        let center = NotificationCenter.default
        let main = OperationQueue.main

        observers.append(center.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: main, using: {
            [weak self] (notification) in
            self?.player?.seek(to: CMTime.zero)
           self?.player?.play()
        }))


        observers.append(
            center.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: main, using: {
                [weak self] (note) in
                guard self?.viewController()?.presentedViewController == nil else { return }
                if let nav = self?.viewController()?.navigationController {
                    if nav.viewControllers.count > 1 { return }
                }
                self?.player?.play()
            })
        )
        
        NotificationCenter.default.addObserver(self, selector: #selector(interruption), name: AVAudioSession.interruptionNotification, object: nil)
    }

    private func unregisterObservers() {
        let center = NotificationCenter.default
        for obj in observers {
            center.removeObserver(obj)
        }
        observers.removeAll()
    }
    
    @objc func interruption() {
        print("👍 ", String(describing: type(of: self)),":", #function, " ", "WE ARE HERE")
    }

}




//extension PromoVideoView: PromoPlayer {
//    var videoURL: URL? {
//        get { return self.url }
//        set {
//            if self.url != newValue {
//                self.url = newValue
//                self.loadVideo()
//            }
//        }
//    }
//
//    func play() {
//        self.player?.play()
//    }
//
//    func pause() {
//        self.player?.pause()
//    }
//}

// Helper function inserted by Swift 4.2 migrator.
//fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
//    return input.//input.rawValue
//}
