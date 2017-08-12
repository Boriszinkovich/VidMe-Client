//
//  VidMeVideo.swift
//  VidMeClient
//
//  Created by User on 12.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import Foundation

struct VidMeVideo
{
    let thumbImageUrlString: String
    let title:String
    let likesCount:Int
}

extension VidMeVideo
{
    init?(json: [String: Any])
    {
        guard let thumbImageUrl = json["thumbnail_url"] as? String,
            let title = json["title"] as? String,
            let likes = json["likes_count"] as? Int
            else
        {
                return nil
        }
        self.thumbImageUrlString = thumbImageUrl
        self.title = title
        self.likesCount = likes
    }
}






























