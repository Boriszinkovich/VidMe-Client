//
//  VideoCell.swift
//  VidMeClient
//
//  Created by User on 13.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import UIKit
import SDWebImage

class VideoCell: UICollectionViewCell
{
    private let theImageViewHeightCoeff: CGFloat = 0.56 // magic 
    @IBOutlet weak var thumbImageView: UIImageView!
    {
        didSet
        {
            self.theHeightConstraint.constant = UIScreen.main.bounds.size.width * theImageViewHeightCoeff
        }
    }
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var theHeightConstraint: NSLayoutConstraint!
    
    public var video: VidMeVideo!
        {
        didSet {
            self.thumbImageView.sd_setImage(with: URL(string: video.thumbImageUrlString), completed: nil)
            self.videoTitleLabel.text = video.title
            self.likesCountLabel.text = video.likesCount == 1 ? "\(video.likesCount) like" : "\(video.likesCount) likes"
        }
    }
}






























