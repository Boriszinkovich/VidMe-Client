//
//  ShowVideoVC.swift
//  VidMeClient
//
//  Created by User on 15.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SnapKit

class ShowVideoVC: UIViewController
{
    var player : AVPlayer? = nil
    var playerLayer : AVPlayerLayer? = nil
    var asset : AVAsset? = nil
    var playerItem: AVPlayerItem? = nil
    var currentVideo: VidMeVideo?
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var videoImageView: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard let currentVideo = currentVideo else
        {
            return
        }

        self.imageViewHeightConstraint.constant = self.videoImageView.bounds.size.width * CGFloat((currentVideo.videoHeight / currentVideo.videoWidth))
        let videoURL = URL(string: currentVideo.videoUrlString)
        
        asset = AVAsset(url:videoURL!)
        playerItem = AVPlayerItem(asset: asset!)
        
        player = AVPlayer(playerItem: self.playerItem)
        
        playerLayer = AVPlayerLayer(player: self.player)
        playerLayer!.frame = self.videoImageView.frame
        
        player!.play()
        player?.addObserver(self, forKeyPath: "status", options: .new, context: nil);
    }
   
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        self.playerLayer!.frame = self.videoImageView.bounds
        self.videoImageView.layer.addSublayer(self.playerLayer!)
        self.view.bringSubview(toFront: self.activityIndicator)
        self.activityIndicator.alpha = 1
        self.activityIndicator.startAnimating()
    }
    
    deinit
    {
        self.removePlayer()
    }
    
    func removePlayer()
    {
        self.player!.pause()
        self.player?.removeObserver(self, forKeyPath: "status")
        self.player = nil
        self.asset = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if let player = object as? AVPlayer,
            let keyPath = keyPath
        {
            if (player == self.player && keyPath.isEqual("status"))
            {
                if (player.status == .readyToPlay)
                {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.alpha = 0
                }
                else if (player.status == .failed)
                {
                    self.player!.play()
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.alpha = 1
                }
            }
        }

    }
}






























