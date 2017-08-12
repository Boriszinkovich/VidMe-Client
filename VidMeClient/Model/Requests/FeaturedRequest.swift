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
    var offset = 0
    var loadCount = 20
    init(offset:UInt, success:FeaturedRequestClosureSuccess?, failure:@escaping VMClosureFailure)
    {
        super.init(failure: failure)
       self.success = success
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
            print(rows)
//            let html = String(data: htmlData!, encoding: String.Encoding.utf8)
//            guard html != nil else {
//                self.handleFailure(nil)
//                return
//            }
//            do {
////                try self.handleSuccess(html!)
//            } catch let error as NSError {
//                self.handleFailure(error)
//            }
        }
        
        let failureBlock = { (task: URLSessionDataTask?, error: Error) -> Void in
            self.handleFailure(error)
        }
        
        self.manager.responseSerializer = AFHTTPResponseSerializer()
        self.request = self.manager.get(urlString, parameters: parameters, progress: nil, success: successBlock, failure: failureBlock)
    }
}
