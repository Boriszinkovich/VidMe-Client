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
    let videoUrlString: String
    let title:String
    let videoId:String
    let likesCount:Int
    let videoHeight: Double
    let videoWidth: Double
}

extension VidMeVideo: Equatable
{
    public static func ==(lhs: VidMeVideo, rhs: VidMeVideo) -> Bool
    {
        return lhs.videoId.isEqual(rhs.videoId)
    }
}

extension VidMeVideo: Hashable
{
    public var hashValue: Int {
        get
        {
            return title.hashValue ^ likesCount ^ videoId.hashValue
        }
    }

}

extension VidMeVideo
{
    init(json: [String: Any]) throws
    {
        print(json)
        guard let thumbImageUrl = json["thumbnail_url"] as? String,
            let title = json["title"] as? String,
            let likes = json["likes_count"] as? Int,
            let videoId = json["video_id"] as? String,
            let videoUrl = json["complete_url"] as? String,
            let videoWidth = json["width"] as? Double,
            let videoHeight = json["height"] as? Double
            else
        {
            throw NSError(domain: "", code: -1, userInfo: nil)
        }
        self.thumbImageUrlString = thumbImageUrl
        self.title = title
        self.likesCount = likes
        self.videoId = videoId
        self.videoUrlString = videoUrl
        self.videoWidth = videoWidth
        self.videoHeight = videoHeight
    }
}






























