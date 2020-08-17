//
//  ContentMusic.swift
//  iList Ambassador
//
//  Created by Mathias Palm on 2016-07-21.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import AVFoundation
import Crashlytics
import AlamofireImage

class ContentMusic: UIView, ContentView {
    
    var horizontalMarginPercent: CGFloat = 0.0
    var bottomMarginPercent: CGFloat = 0.0
    var marginEdgePercentage: CGFloat = 0.0
    var view: UIView { return self }
    var height:CGFloat = 0.0
    var width: CGFloat = 0.0

    var audioPlayer: Player?
    var isPlaying = false
    var timer:Timer?
    var playerIsShowing = true
    var duration = 0.0
    
    var circularProgress: CircularProgress?
    var playImg = UIImage(named: "play-white")
    var pauseImg = UIImage(named: "pause-white")

    lazy var timeLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = Color.whiteColor()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.italicFont(FontSize.Normal)
        return label
    }()
    
    lazy var imageView : CircularImageView = {
        let imageView:CircularImageView = CircularImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var overlay: UIView = {
       let overlay = UIView(frame: CGRect.zero)
        overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        overlay.alpha = 0
        return overlay
    }()
    
    lazy var button : Button = {
        let button = Button(frame: CGRect.zero)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "play-white"), for: UIControlState())
        button.alpha = 0
        button.addTarget(self, action:#selector(togglePlay), for: .touchUpInside)
        return button
    }()
    
    init(frame: CGRect, file: String, thumb: String?) {
        super.init(frame:frame)
        audioPlayer = MPCacher.sharedInstance.getObjectForKey(file) as? Player
        audioPlayer?.isMuted = false
        audioPlayer?.volume = 0.5
        height = frame.size.height
        width = frame.size.width
        clipsToBounds = true
        
        if let thumb = thumb {
            if let url = URL(string: thumb) {
                imageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.crossDissolve(0.2), runImageTransitionIfCached: true, completion: { _ in
                    self.overlay.alpha = 1
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        self.button.alpha = 1
                    })
                })
                setupMusic()
            }
        }
    }
    
    func setupMusic() {
        addSubview(imageView)
        addSubview(timeLabel)
        let size = width*0.8
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageview(size)]-5-[label]|", options: [], metrics: ["size":size], views: ["imageview" : imageView, "label": timeLabel]))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1.0, constant: size))
        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))

        circularProgress = CircularProgress(frame: CGRect(x: 0, y: 0, width: size, height: size))
        addViewToImage(overlay)
        addViewToImage(circularProgress!)
        addViewToImage(button)
        updateTime()
        if let audioPlayer = audioPlayer, let currentItem = audioPlayer.currentItem {
            let duration = currentItem.asset.duration.seconds
            self.duration = duration
            timeLabel.text = String(format: "00:00 / %02i:%02i", Int(floor(duration.truncatingRemainder(dividingBy: 3600) / 60)), Int(floor(duration.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))))
        }
    }
    
    func prepareForReuse() {
        self.imageView.af_cancelImageRequest()
        self.imageView.image = nil
        timeLabel.text = "00:00 / 00:00"
    }
    
    func addViewToImage(_ view: UIView) {
        imageView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        imageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subview]|", options: [], metrics: nil, views: ["subview" : view]))
        imageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subview]|", options: [], metrics: nil, views: ["subview" : view]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        playerIsShowing = false
        if let player = audioPlayer {
            player.pause()
            button.setImage(playImg, for: UIControlState())
            isPlaying = false
            if let timer = timer {
                timer.invalidate()
            }
            let seekTime: CMTime = CMTimeMake(0, 1)
            player.seek(to: seekTime)
        }
    }
    
    @objc func togglePlay() {
        playerIsShowing = true
        if isPlaying {
            audioPlayer?.pause()
            button.setImage(playImg, for: UIControlState())
            if let timer = timer {
                timer.invalidate()
            }
            isPlaying = false
        } else {
            isPlaying = true
            audioPlayer?.play()
            button.setImage(pauseImg, for: UIControlState())
            startTimer()
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    @objc  
    func updateTime() {
        if let audioPlayer = audioPlayer, let currentItem = audioPlayer.currentItem {
            let current = currentItem.currentTime().seconds
            let minutes = floor(current.truncatingRemainder(dividingBy: 3600) / 60)
            let seconds = floor(current.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))
            if current > 0.0 {
                timeLabel.text = String(format: "%02i:%02i / %02i:%02i", Int(minutes), Int(seconds), Int(floor(duration.truncatingRemainder(dividingBy: 3600) / 60)), Int(floor(duration.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60)))
                circularProgress?.progress = current / duration
            }
        }
    }
    
}
