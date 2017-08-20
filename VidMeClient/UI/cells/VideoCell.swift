//
//  VideoCell.swift
//  VidMeClient
//
//  Created by User on 13.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation



class VideoCell: UICollectionViewCell
{
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var theHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var soundImageView: UIImageView!
    {
        didSet
        {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(soundImageViewTapped(_:)))
            soundImageView.addGestureRecognizer(gesture)
        }
    }
    private var observerTrullyAdded = false
    
    private var player : AVPlayer? = nil
    private var asset : AVURLAsset? = nil
    private var playerItem: AVPlayerItem? = nil
    public var hasSound: Bool = true
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        if self.isPlaying != nil && self.isPlaying == true && playerLayer != nil
        {
            self.playerLayer?.frame = self.thumbImageView.bounds
            self.thumbImageView.layer.addSublayer(playerLayer!)
        }
    }
    
    var playerLayer: AVPlayerLayer?
    public var isPlaying: Bool?
    {
        didSet
        {
            if isPlaying == true && oldValue == false
            {
                self.startPlaying()
                self.layoutSubviews()
                self.cameraImageView.alpha = 1;
            }
            else
            {
                self.cameraImageView.alpha = 0;
                if oldValue != nil && oldValue == true
                {
                    self.stopPlaying()
                }
            }
        }
    }
    
    public var video: VidMeVideo!
        {
        didSet
        {
            if (video == nil || (oldValue != nil && video == oldValue))
            {
                return
            }
            self.isPlaying = video.isVideoPlaying
            self.videoTitleLabel.text = video.title
            self.likesCountLabel.text = video.likesCount == 1 ? "\(video.likesCount) like" : "\(video.likesCount) likes"
            self.theHeightConstraint.constant = UIScreen.main.bounds.size.width * CGFloat(video.videoHeight / video.videoWidth)
            self.thumbImageView.sd_setImage(with: URL(string: video.thumbImageUrlString), completed: nil)
        }
    }
    
    func soundImageViewTapped(_ gesture: UITapGestureRecognizer)
    {
        self.hasSound = !self.hasSound
        self.muteSound(mute: !self.hasSound)
        if self.hasSound
        {
            self.soundImageView!.image = UIImage(named:"icon_Sound")
        }
        else
        {
            self.soundImageView!.image = UIImage(named:"icon_NoSound")
        }
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.soundChangeNotification), object: self.hasSound)
    }
    
    func startPlaying()
    {
        if let videoUrlString = self.video.smallestVideoUrlString
        {
            self.cameraImageView.alpha = 1
            DispatchQueue.global().async
                {
                let keys = ["tracks", "duration"]
                self.asset = AVURLAsset(url:URL(string: videoUrlString)!)
                self.asset!.loadValuesAsynchronously(forKeys: keys, completionHandler:
                {
                    var keyStatusError: NSError?
                    for key in keys {
                        var error: NSError?
                        let keyStatus: AVKeyValueStatus = (self.asset?.statusOfValue(forKey: key, error: &error))!
                        if keyStatus == .failed {
                            let userInfo = [NSUnderlyingErrorKey : key]
                            keyStatusError = NSError(domain: "", code: -1, userInfo: userInfo)
                        }
                        else if keyStatus != .loaded {

                        }
                    }
                    if keyStatusError == nil
                    {
                        if self.isPlaying != nil && self.isPlaying! == true
                        {
                            DispatchQueue.main.async {
                                self.playerItem = AVPlayerItem(asset: self.asset!)
                                
                                self.player = AVPlayer(playerItem: self.playerItem)
                                self.playerLayer = AVPlayerLayer(player: self.player)
                                self.layoutSubviews()
                                self.player?.play()
                                self.observerTrullyAdded = true
                                self.player!.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil);
                            }
                        }
                    }
                })
            }
        }
    }
    
    func stopPlaying()
    {
        self.playerLayer?.removeFromSuperlayer()
        self.player?.pause()
        if self.observerTrullyAdded == true
        {
            self.player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
            self.observerTrullyAdded = false
        }
        self.asset?.cancelLoading()
        self.player = nil
        self.playerLayer = nil
        self.soundImageView.alpha = 0
    }
    
    private func adjustToPlayerReadyState()
    {
        self.cameraImageView.alpha = 0
        self.soundImageView.alpha = 1
        self.muteSound(mute: !self.hasSound)
        if self.hasSound
        {
            self.soundImageView!.image = UIImage(named:"icon_Sound")
        }
        else
        {
            self.soundImageView!.image = UIImage(named:"icon_NoSound")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if let player = object as? AVPlayer,
            let keyPath = keyPath
        {
            if (player == self.player && keyPath.isEqual("currentItem.loadedTimeRanges"))
            {
                let ready = player.status == .readyToPlay
                
                let timeRange = player.currentItem?.loadedTimeRanges.first as? CMTimeRange
                guard let duration = timeRange?.duration else { return  } // Fail when loadedTimeRanges is empty
                let timeLoaded = Int(duration.value) / Int(duration.timescale) // value/timescale = seconds
                let loaded = timeLoaded > 0
                
                if ready && loaded
                {
                    self.adjustToPlayerReadyState() // player is ready
                }
            }
        }
    }
    
    private func muteSound(mute: Bool)
    {
        self.player?.isMuted = mute
    }
}

extension VideoCell: VidMeVideoPlayingListener
{
    func videoChangedPlaying(isPlaying: Bool)
    {
        self.isPlaying = isPlaying
    }
}





























