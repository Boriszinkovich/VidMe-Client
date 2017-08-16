//
//  FeedRequest.swift
//  VidMeClient
//
//  Created by User on 15.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import Foundation
import AFNetworking

typealias FeedRequestClosureSuccess = (_ videos: [VidMeVideo]) -> Void

class FeedRequest: VidMeRequest
{
    var request: URLSessionDataTask?
    var success: FeedRequestClosureSuccess?
    var offset: UInt = 0
    var loadCount: UInt = 10
    var accessToken: AccessToken!
    init(offset: UInt, accessToken:AccessToken, success: FeedRequestClosureSuccess?, failure: @escaping VMClosureFailure)
    {
        super.init(failure: failure)
        self.success = success
        self.offset = offset
        self.accessToken = accessToken
        send()
    }
   
    override func send()
    {
        let urlString = VidMeRequest.host + "/videos/feed"
        let parameters = ["offset" : offset, "limit" : loadCount]
        let successBlock = { (task: URLSessionDataTask, responseObject: Any?) -> Void in
            let jsonData = responseObject as? Data
            guard let data = jsonData,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else
            {
                self.handleFailure(nil)
                return
            }
            guard let rows = json!["videos"] as? [[String: Any]] else
            {
                self.handleFailure(nil)
                return
            }
            do {
                let videos = try rows.flatMap({ (videoDict) -> VidMeVideo? in
                    return try VidMeVideo(json: videoDict)
                })
                self.success?(videos)
            } catch let error as NSError
            {
                self.handleFailure(error)
                return
            }
        }
        let failureBlock = { (task: URLSessionDataTask?, error: Error) -> Void in
            self.handleFailure(error)
        }
        self.manager.responseSerializer = AFHTTPResponseSerializer()
        self.manager.requestSerializer.setValue(self.accessToken.value, forHTTPHeaderField: "AccessToken")
        self.request = self.manager.get(urlString, parameters: parameters, progress: nil, success: successBlock, failure: failureBlock)
    }
}






























