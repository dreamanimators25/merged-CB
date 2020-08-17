//
//  ContentEmbed.swift
//  iList Ambassador
//
//  Created by Dmitriy Zhyzhko on 09.07.2018.
//  Copyright © 2018 iList AB. All rights reserved.
//

import Foundation
import UIKit
import YouTubePlayer
import HCVimeoVideoExtractor
import AVFoundation
import AVKit

class ContentEmbed: UIView, ContentView {
    var view: UIView { return self }
    var horizontalMarginPercent: CGFloat = 0.0
    var bottomMarginPercent: CGFloat = 0.0
    var marginEdgePercentage: CGFloat = 0.0
    var height: CGFloat = 0.0
    var width: CGFloat = 0.0
    var cent: CGPoint!
    
    var videoPlayer: YouTubePlayerView!
    
    func prepareForReuse() {
        
    }
    
    init(frame: CGRect, url: String, CNTR : CGPoint) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black

        height = frame.size.height
        width = frame.size.width
        clipsToBounds = true
        
        cent = CNTR
        bottomMarginPercent = 100.0
    
        videoPlayer = YouTubePlayerView(frame: frame)
        
        let split = url.split(separator: "/")
        if let embed  = split.last {
            let id =  String.init(embed).replacingOccurrences(of: "\"", with: "")
            videoPlayer.loadVideoID(id)
            addSubview(videoPlayer)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        //TODO impl setup method
    }
}


class ContentEmbedVimeo: UIView, ContentView {
    
    var view: UIView { return self }
    var horizontalMarginPercent: CGFloat = 0.0
    var bottomMarginPercent: CGFloat = 0.0
    var marginEdgePercentage: CGFloat = 0.0
    var height: CGFloat = 0.0
    var width: CGFloat = 0.0
    var cent: CGPoint!
    
    
    var vimeoUrl : String?
    
    func prepareForReuse() {
        
    }
    
    init(frame: CGRect, url: String,CNTR : CGPoint) {
        super.init(frame: frame)
        let screenWidht = SCREENSIZE.width
        
        self.backgroundColor = UIColor.white
        height = screenWidht * 0.8
        width = screenWidht
        clipsToBounds = true
        
        cent = CNTR
        bottomMarginPercent = 80.0
        
        let btn_vimeo = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 70, height: 70))
        btn_vimeo.center = self.center
        btn_vimeo.setImage(UIImage.init(named: "play-button"), for: .normal)
        btn_vimeo.addTarget(self, action: #selector(self.playVimeo), for: .touchUpInside)
        
        
        self.vimeoUrl = url
        self.addSubview(btn_vimeo)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        //TODO impl setup method
    }
    
    @objc func playVimeo() {
        if let vim = loadVimeoPlayer {
            vim(vimeoUrl ?? "")
        }
    }
    
   
}
