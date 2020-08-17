//
//  ContentBackgroundMediaView.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 10/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import AVFoundation

class ContentBackgroundMediaView: UIView {
    
    // MARK: Views
    lazy var overlayView: UIView = {
        let overlayView = UIView(frame: SCREENSIZE)
        overlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        overlayView.hidden = true
        return overlayView
    }()
    
    lazy var coloredView: UIView = {
        let coloredView = UIView()
        return coloredView
    }()
    var imageView: UIImageView = {
        let imageView = UIImageView(frame: SCREENSIZE)
        imageView.backgroundColor = UIColor.clearColor()
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        return imageView
    }()
    var videoView: UIView = {
        let videoView = UIView(frame: SCREENSIZE)
        videoView.backgroundColor = UIColor.clearColor()
        return videoView
    }()
    var playerLayer:AVPlayerLayer?
    // MARK: - View life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.clearColor()
        clipsToBounds = false
        func addBackgroundSubview(subview: UIView) {
            subview.translatesAutoresizingMaskIntoConstraints = false
            addSubview(subview)
            let views = ["subview" : subview]
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subview]|", options: .AlignAllBaseline, metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subview]|", options: .AlignAllBaseline, metrics: nil, views: views))
        }
        addBackgroundSubview(coloredView)
        addBackgroundSubview(imageView)
        addBackgroundSubview(videoView)
        addBackgroundSubview(overlayView)
    }
    
    func prepareForReuse() {
        coloredView.hidden = true
        imageView.hidden = true
        videoView.hidden = true
    }
    
    // MARK: - Private functions
    
    private func setViewVisible(view: UIView?) {
        coloredView.hidden = (view != coloredView)
        imageView.hidden = (view != imageView)
        videoView.hidden = (view != videoView)
    }
    
    // MARK: - Info
    
    func updateWithColor(color: UIColor) {
        coloredView.backgroundColor = color
        setViewVisible(coloredView)
//        overlayView.hidden = true
    }
    
    func updateWithColorString(colorString: String) {
        updateWithColor(UIColor(hexString: colorString))
    }
    let plImg = UIImage(named: "background.jpg")
    func updateWithImageUrl(imageUrlString: String) {
        if let imageUrl = NSURL(string: imageUrlString) {
            imageView.af_setImageWithURL(imageUrl, placeholderImage: plImg)
            setViewVisible(imageView)
//            overlayView.hidden = false
        }
    }
    /*
    func videoSnapshot(player:LoopingPlayer) -> UIImage? {
        guard let item = player.currentItem else  {
            return nil
        }
        let generator = AVAssetImageGenerator(asset: item.asset)
        generator.appliesPreferredTrackTransform = true

        let timestamp = player.currentTime()
        
        do {
            let imageRef = try generator.copyCGImageAtTime(timestamp, actualTime: nil)
            return UIImage(CGImage: imageRef)
        } catch let error as NSError {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    func setUpPlayer(player: LoopingPlayer) {
        backgroundThread(background: {
            if let layer = self.playerLayer {
                layer.removeFromSuperlayer()
            }
            self.playerLayer = AVPlayerLayer(player: player)
            self.playerLayer!.frame = SCREENSIZE
            self.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            },
            completion: {
                self.videoView.layer.addSublayer(self.playerLayer!)
                self.setViewVisible(self.videoView)
                player.play()
        })
    }
    func updateWithVideo(video: LoopingPlayer) {
        video.restartVideoFromBeginning()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        if imageView.image == nil {
            let img = videoSnapshot(video)
            imageView.image = img
            setViewVisible(imageView)
        }
        setUpPlayer(video)
    }
    */
    func updateWithTransparentBackground() {
        setViewVisible(nil)
    }
}