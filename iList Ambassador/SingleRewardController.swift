//
//  SingleRewardController.swift
//  iList Ambassador
//
//  Created by Adam Woods on 2017-08-07.
//  Copyright © 2017 iList AB. All rights reserved.
//

import UIKit
import AlamofireImage
import AVFoundation
import AVKit
import Alamofire

class SingleRewardController: UIViewController {

    private var iconImage: UIImage?
    private var rewardsArray = [RewardList]()
    var singleRewardMetaData: Reward?
    private var fontSize = CGFloat(20)
    private var titleTextColor = UIColor.white
    private var titleTextWeight = UIColor.black
    private var titleTextActual = "NO TEXT AVAILABLE"
    private var backgroundVideoUrl: String?
    private var videoURL: URL?
    private var player = AVPlayer()
    private var playerLayer = AVPlayerLayer()
    private var soundPlayer = AVPlayer()
    private var soundUrl: URL?
    private var soundLayer = AVPlayerLayer()
    
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var soundToggle: UIButton!
    @IBOutlet weak var frameImage: UIImageView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var bodyImage: UIImageView!
    @IBOutlet weak var bodyText: UITextField!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var useButton: UIButton!
    
    @IBAction func close(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
   
    @IBAction func toggleSoundButtonpressed(_ sender: Any) {
        if self.soundPlayer.isMuted {
            self.soundPlayer.isMuted = false
        } else {
            self.soundPlayer.isMuted = true
        }
    }
    
    @IBAction func useButtonTapped(_ sender: Any) {
        print("Send use signal to backend")
        ShowActionSheet()
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "shareRewardSegue", sender: sender)
    }
    
    // TODO: Redo so there's only one player for both video and sound, and either can be muted
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.imageView?.contentMode = .scaleAspectFit
        soundToggle.alpha = 1
        setupView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.player.pause()
        self.soundPlayer.pause()
    }
    
        
    private func ShowActionSheet() {
        let sheet = UIAlertController(title: "Confirm", message: "", preferredStyle: .actionSheet)
        let ok = UIAlertAction(title: "Ok", style: .default) { action in
            self.removeSingleReward((self.singleRewardMetaData?.id)!)
        
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(ok)
        sheet.addAction(cancel)
        
        present(sheet, animated: true, completion: nil)
    }
    
    
    
    private func removeSingleReward(_ id: Int) {
        RewardManager.sharedInstance.useReward(id) { (code) in
            if code! > 300 {
                print("Error using reward")
                
            } else {
                self.performSegue(withIdentifier: "returnToProfileSegue", sender: self)
                
                print("Reward was successfully used")
            }
            
        }
    }
    
    private func setupView() {
        if singleRewardMetaData?.pages[0] != nil {
            setupBackgroundSound()
            setupBackground()
            setupFrame()
            setupComponents()
        } else {
            self.bodyText.text = "Unable to retrieve reward, please try again"
        }
        useButton.backgroundColor = .clear
        useButton.imageView?.contentMode = .scaleAspectFit
        shareButton.backgroundColor = .clear
        shareButton.imageView?.contentMode = .scaleAspectFit
    }
    
    private func setupBackgroundSound() {
        if singleRewardMetaData?.pages[0].backgroundSound != nil {
            self.soundUrl = URL(string: (singleRewardMetaData?.pages[0].backgroundSound)!)
            self.soundPlayer = AVPlayer(url: soundUrl!)
            self.soundPlayer.play()
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.soundPlayer.currentItem, queue: nil, using: { (_) in
                DispatchQueue.main.async {
                    self.soundPlayer.seek(to: CMTime.zero)
                    self.soundPlayer.play()
                }
            })
        }
    }
    
    private func setupBody() {
        for x in (singleRewardMetaData?.pages[0].components)! {
            switch x.type.rawValue {
            case "image":
                self.bodyImage.contentMode = .scaleAspectFit
                self.bodyImage.af_setImage(withURL: URL(string: (x.file)!)!)
                self.bodyText.isHidden = true
            case "text":
                if x.meta?.size == 16 {
                    self.bodyText.text = x.meta?.text
                } else {
                    self.titleText.text = x.meta?.text
                }
            case "video":
                    setVideo(0, fileURL: URL(string: x.file!)!)
            default:
                return
            }
        }
    }
    
    private func setupBackground() {
        let backgroundData = singleRewardMetaData?.pages[0].background
        guard let type = backgroundData?.type.rawValue else { return }
        
        switch type {
        case "video":
            setVideo(-1, fileURL: URL(string: (backgroundData?.fileUrl)!)!)
        case "image":
            setImageBackground()
        case "color":
            setColorBackground()
        default:
            return
        }
    }
    
    private func setImageBackground() {
        backgroundImage.contentMode = .scaleAspectFill
        if let background = singleRewardMetaData?.pages[0].background?.fileUrl {
            backgroundImage.af_setImage(withURL: URL(string: background)!)
        } else if let background = singleRewardMetaData?.pages[0].background?.file {
            backgroundImage.af_setImage(withURL: URL(string: background)!)
        }
    }
    
    private func setVideo(_ layer: Int, fileURL: URL) {
        soundToggle.alpha = 1
        self.videoURL = fileURL
        self.player = AVPlayer(url: videoURL!)
        self.playerLayer = AVPlayerLayer(player: player)
        self.playerLayer.frame = self.view.bounds
        self.playerLayer.zPosition = CGFloat(layer)
        self.view.layer.addSublayer(playerLayer)
        self.player.play()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                self.player.seek(to: CMTime.zero)
                self.player.play()
            }
        })
    }
    
    private func setColorBackground() {
        if let colorValue = singleRewardMetaData?.pages[0].background?.meta.color {
            view.backgroundColor = UIColor(hexString: colorValue)
        }
        
    }
    
    private func setupFrame() {
        if singleRewardMetaData?.pages[0].frame != nil {
            frameImage.af_setImage(withURL: URL(string: (singleRewardMetaData?.pages[0].frame)!)!)
        }
        
    }
    
    private func setupComponents() {
        if (singleRewardMetaData?.pages[0].components.count)! > 0 {
            let components = singleRewardMetaData?.pages[0].components[0]
            if (components?.meta?.size) != nil {
                self.fontSize = (components?.meta?.size)! }
            if (components?.meta?.color) != nil {
                self.titleTextColor = (components?.meta?.color)!
            }
            if (components?.meta?.text) != nil {
                self.titleTextActual = (components?.meta?.text)!
            }
            setupBody()
            setupTitle()
        }
    }
    
    private func setupTitle() {
        titleText.font = titleText.font?.withSize(self.fontSize)
        titleText.backgroundColor = .clear
        titleText.textColor = self.titleTextColor
        titleText.text = self.titleTextActual
    }
}
