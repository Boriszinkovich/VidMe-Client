//
//  VidMeVideo.swift
//  VidMeClient
//
//  Created by User on 12.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import Foundation

protocol VidMeVideoPlayingListener: NSObjectProtocol
{
    func videoChangedPlaying(isPlaying: Bool)
}

struct VidMeVideoFormat
{
    let formatType: String
    let formatUrl: String
}

extension VidMeVideoFormat
{
    init(json: [String: Any]) throws
    {
        guard let type = json["type"] as? String,
        let uri = json["uri"] as? String
            else
        {
            throw NSError(domain: "", code: -1, userInfo: nil)
        }
        formatType = type
        formatUrl = uri
    }
}

class VidMeVideo
{
    var thumbImageUrlString: String
    var videoUrlString: String?
    var smallestVideoUrlString: String?
    var title:String
    var videoId:String
    var likesCount:Int
    var videoHeight: Double
    var videoWidth: Double
    var isVideoPlaying: Bool = false
    {
        didSet
        {
            if oldValue == isVideoPlaying
            {
                return
            }
            self.playingListener?.videoChangedPlaying(isPlaying: isVideoPlaying)
        }
    }
    weak var playingListener: VidMeVideoPlayingListener? = nil
        
    init(json: [String: Any]) throws
    {
        guard let thumbImageUrl = json["thumbnail_url"] as? String,
            let title = json["title"] as? String,
            let likes = json["likes_count"] as? Int,
            let videoId = json["video_id"] as? String,
            let videoWidth = json["width"] as? Double,
            let videoHeight = json["height"] as? Double,
            let formats = json["formats"] as? [[String: Any]]
            else
        {
            throw NSError(domain: "", code: -1, userInfo: nil)
        }
        self.thumbImageUrlString = thumbImageUrl
        self.title = title
        self.likesCount = likes
        self.videoId = videoId
        self.videoWidth = videoWidth
        self.videoHeight = videoHeight
        do {
            let formats = try formats.flatMap({ (formatDict) -> VidMeVideoFormat? in
                return try VidMeVideoFormat(json: formatDict)
            })
            self.smallestVideoUrlString = formats.last?.formatUrl
            self.videoUrlString = formats.first?.formatUrl
        } catch let error as NSError
        {
            throw error
        }
    }
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
































