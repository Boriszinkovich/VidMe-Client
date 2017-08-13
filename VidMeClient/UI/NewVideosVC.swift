//
//  NewVideosVC.swift
//  VidMeClient
//
//  Created by User on 13.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import UIKit

class NewVideosVC: VideoListVC
{
    override func methodLoadVideos(offset:UInt)
    {
        _ = WebService.sharedInstance.getNewVideosList(offset: offset, success: {(response) in
            self.handleNewVideos(videos: response, refreshing:offset == 0)
        }, failure: { (error) in
            self.handleErrorVideos(refreshing: offset == 0, error: error)
        })
    }
}






























