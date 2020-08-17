//
//  ContentVideo.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-07-21.
//  Copyright © 2016 iList AB. All rights reserved.
//

import AVFoundation
import UIKit

class ContentVideo: UIView, ContentView {
    
    var topMarginPercent: CGFloat = 0.0
    var horizontalMarginPercent: CGFloat = 0.0
    var bottomMarginPercent: CGFloat = 0.0
    var marginEdgePercentage: CGFloat = 0.0
    var view: UIView { return self }
    var height:CGFloat = 0.0
    var width: CGFloat = 0.0
    
    var player: Player?
    var playerLayer: AVPlayerLayer?
    var videoThumbView: UIImageView?
    var playerIsShowing = true
    var inlinePlayer = false
    var inlinePlayerIsedPaused = false
    
    var cent: CGPoint! //Sameer 6/5/2020

    lazy var button : Button = {
        let button = Button(frame: self.frame)
        button.addTarget(self, action:#selector(play), for: .touchUpInside)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "play-button"), for: UIControl.State())
        return button
    }()
    
    //Sameer 6/5/2020 CNTR Added for center
    init(frame: CGRect, file: String, inlinePlayer: Bool = false, CNTR : CGPoint = CGPoint(x: 0,y: 0)) {
        super.init(frame: frame)
        self.inlinePlayer = inlinePlayer
        self.backgroundColor = UIColor.black 
        if let item = MPCacher.sharedInstance.getObjectForKey(file) as? Player {
            setThumb(item, file: file)
        } else {
            tryLoadVideo(file)
        }

        height = frame.size.height
        width = frame.size.width
        clipsToBounds = true
        
        //Sameer 6/5/2020
        if CNTR.x != 0 {
            cent = CNTR
            //bottomMarginPercent = 100.0
        }
        
        blockPlayBack = { 
            //self.playbackLikelyToKeepUp()
        }
    }
    
    func prepareForReuse() {
        videoThumbView?.af_cancelImageRequest()
        videoThumbView?.image = nil
        reset()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tryLoadVideo(_ file: String) {
        delay(5, closure: {
            DispatchQueue.main.async(execute: {
                if let item = MPCacher.sharedInstance.getObjectForKey(file) as? Player {
                    self.setThumb(item, file: file)
                } else {
                    self.tryLoadVideo(file)
                }
            })
        })
    }
    
    func setup(_ player: Player) {
        if self.player != player {
            self.player = player
            self.player?.delegate = self
            setupLayer(player)
        }
    }
    
    func setupLayer(_ player: Player) {
        if playerLayer == nil {
            playerLayer = AVPlayerLayer(player: player)
            if let playerLayer = playerLayer {
                playerLayer.frame = bounds
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                layer.addSublayer(playerLayer)
                if let videoThumbView = videoThumbView {
                    bringSubviewToFront(videoThumbView)
                    if inlinePlayer {
                        setInteractive()
                    }
                }
            }
        }
    }
    
    func setThumb(_ player: Player, file: String) {
        if videoThumbView == nil {
            videoThumbView = UIImageView(frame: self.frame)
            addBackgrounsSubview(videoThumbView!)
            videoThumbView?.contentMode = .scaleAspectFill
        }
        let cachedImg = MPCacher.sharedInstance.getObjectForKey("\(file).thumb")
        if let cachedImg = cachedImg as? UIImage {
            setImg(player, image: cachedImg)
        } else {
            generateThumb(player, file: file)
        }
    }
    
    func setImg(_ player: Player, image: UIImage) {
        if let videoThumbView = self.videoThumbView {
            videoThumbView.image = image
            if !inlinePlayer {
                videoThumbView.makeBlurImage()
            }
            videoThumbView.alpha = 0
            UIView.animate(withDuration: 0.2, animations: {
                videoThumbView.alpha = 1
                }, completion: {
                    finished in
                    self.setup(player)
            })
        }
    }
    
    func generateThumb(_ player: Player, file: String) {
        if let item = player.currentItem {
            makeVideoThumb(item, completion: {
                image in
                DispatchQueue.main.async(execute: {
                    if let image = image {
                        MPCacher.sharedInstance.setObjectForKey(image, key: "\(file).thumb")
                        self.setImg(player, image: image)
                    } else {
                        self.setup(player)
                    }
                })
            })
        }
    }
    
    func reset() {
        playerIsShowing = false
        if let player = player {
            player.pause()
            let seekTime: CMTime = CMTimeMake(value: 0, timescale: 1)
            player.seek(to: seekTime)
        }
        showThumb()
    }
    
    @objc func play(muted: Bool = false) {
        playerIsShowing = true
        if let player = player {
            player.isMuted = muted
            if inlinePlayer && player.rate > 0 {
                button.imageView?.alpha = 1
                player.pause()
                inlinePlayerIsedPaused = true
            } else {
                if inlinePlayer {
                    button.startLoading()
                    inlinePlayerIsedPaused = false
                }
                player.testKeepUp()
            }
        }
    }
    
    func setInteractive() {
        reset()
        addBackgrounsSubview(button)
    }
    
    func addBackgrounsSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        let views = ["subview" : view]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subview]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subview]|", options: [], metrics: nil, views: views))
    }
    
    func makeVideoThumb(_ item: AVPlayerItem, completion: @escaping (_ image:UIImage?) -> ()) {
        let generator = AVAssetImageGenerator(asset: item.asset)
        generator.appliesPreferredTrackTransform = true
        var snapShotSecond: Int64 = 1
        if inlinePlayer && item.duration.seconds > 0 {
            snapShotSecond = Int64(item.duration.seconds / 2)
        }

        let timestamp = CMTimeMake(value: snapShotSecond, timescale: 1)
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: timestamp)], completionHandler: {
            _, image,_,_,error in
            if let image = image {
                completion(UIImage(cgImage: image))
            } else {
                completion(nil)
            }
        })
    }
    
    func showThumb() {
        videoThumbView?.alpha = 1
    }
    
}

extension ContentVideo: PlayerDelegate {
    func playbackLikelyToKeepUp() {
        if let player = player, playerIsShowing && player.rate == 0 && !inlinePlayerIsedPaused {
            player.preroll(atRate: 1.0, completionHandler: {
                finished in
                if self.inlinePlayer {
                    self.button.stopLoading()
                    self.button.imageView?.alpha = 0
                }
                player.play()
            })
            UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseOut, animations: {
                self.videoThumbView?.alpha = 0
            }, completion: nil)
        }
    }
}

