//
//  ContentPageComponentVideoView.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 12/06/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import MediaPlayer

class ContentPageComponentVideoView : UIView, ContentPageComponentProtocol {
    
    var heightConstraint: NSLayoutConstraint?
    var calculatedHeight: CGFloat = 80.0
    var prefferdMargin:CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init(videoUrlString: String) {
        self.init(frame: CGRectZero)
        if let videoUrl = NSURL(string: videoUrlString) {
            setVideoFromUrl(videoUrl)
        }
    }
    
    lazy var moviePlayer: MPMoviePlayerController = {
        let moviePlayer = MPMoviePlayerController()
        moviePlayer.view.translatesAutoresizingMaskIntoConstraints = false
        moviePlayer.movieSourceType = MPMovieSourceType.Streaming
        moviePlayer.controlStyle = MPMovieControlStyle.Embedded
        return moviePlayer
    }()
    
    private func setup() {
        backgroundColor = UIColor.clearColor()
        contentMode = .ScaleAspectFit
        
        addSubview(moviePlayer.view)
        
        let views = ["moviePlayer":moviePlayer.view]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[moviePlayer]|", options: .AlignAllBaseline, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[moviePlayer]|", options: .AlignAllBaseline, metrics: nil, views: views))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let heightConstraint = heightConstraint {
            heightConstraint.constant = calculatedHeight
        }
    }
    func reset() {
        moviePlayer.stop()
    }
    // MARK: - Image
    
    func setVideoFromUrl(imageUrl: NSURL) {
        moviePlayer.prepareToPlay()
        moviePlayer.contentURL = imageUrl
        moviePlayer.play()
        //        let newHeight = (CGRectGetWidth(self.bounds)/moviePlayer.naturalSize.width)*moviePlayer.naturalSize.height
        self.calculatedHeight = SCREENSIZE.height - 2.0*16.0 // Top + bottom margin
        //        calculatedHeight = moviePlayer.naturalSize.height
    }
    
    // MARK: - ContentPageComponentHeightProtocol
    
    func view() -> UIView {
        return self
    }
    
    func updateWithHeightConstraint(heightConstraint: NSLayoutConstraint) {
        self.heightConstraint = heightConstraint
    }
    
    func updateHeightForComponentWithWidth(width: CGFloat) {
        // Not used here..
    }
    
    func prefferedMargin() -> CGFloat {
        return self.prefferdMargin
    }
    
    func prepareForReuse() {
        moviePlayer.stop()
    }
    
}
