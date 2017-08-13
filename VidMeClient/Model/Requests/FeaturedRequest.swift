//
//  FeaturedRequest.swift
//  VidMeClient
//
//  Created by User on 12.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import Foundation
import AFNetworking

typealias FeaturedRequestClosureSuccess = (_ videos: [VidMeVideo]) -> Void

class FeaturedRequest: VidMeRequest
{
    var request: URLSessionDataTask?
    var success:FeaturedRequestClosureSuccess?
    var offset: UInt = 0
    var loadCount = 10
    init(offset:UInt, success:FeaturedRequestClosureSuccess?, failure:@escaping VMClosureFailure)
    {
        super.init(failure: failure)
       self.success = success
        self.offset = offset
        send()
    }
    
    
    override func send()
    {
        let urlString = VidMeRequest.host + "/videos/featured"
        let parameters = ["offset" : offset]
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
            print(rows)
        }
        
        let failureBlock = { (task: URLSessionDataTask?, error: Error) -> Void in
            self.handleFailure(error)
        }
        
        self.manager.responseSerializer = AFHTTPResponseSerializer()
        self.request = self.manager.get(urlString, parameters: parameters, progress: nil, success: successBlock, failure: failureBlock)
    }
}






























