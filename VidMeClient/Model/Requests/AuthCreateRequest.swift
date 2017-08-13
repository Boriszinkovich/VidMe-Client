//
//  AuthCreateRequest.swift
//  VidMeClient
//
//  Created by User on 13.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import Foundation
import AFNetworking

typealias AuthCreateRequestClosureSuccess = (_ created: Bool, _ token: String) -> Void

class AuthCreateRequest: VidMeRequest
{
    var request: URLSessionDataTask?
    var success:AuthCreateRequestClosureSuccess?
    var password:String?
    var login:String?
    init(password:String, login: String, success:AuthCreateRequestClosureSuccess?, failure:@escaping VMClosureFailure)
    {
        super.init(failure: failure)
        self.success = success
        send()
    }
    
    
    override func send()
    {
        let urlString = VidMeRequest.host + "/auth/create"
        let parameters = ["username" : self.login, "password" : self.password]
        let successBlock = { (task: URLSessionDataTask, responseObject: Any?) -> Void in
//            let jsonData = responseObject as? Data
//            guard let data = jsonData,
//                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else
//            {
//                self.handleFailure(nil)
//                return
//            }
//            guard let rows = json!["videos"] as? [[String: Any]] else
//            {
//                self.handleFailure(nil)
//                return
//            }
//            do {
//                let videos = try rows.flatMap({ (videoDict) -> VidMeVideo? in
//                    return try VidMeVideo(json: videoDict)
//                })
//                self.success?(videos)
//            } catch let error as NSError
//            {
//                self.handleFailure(error)
//                return
//            }
//            print(rows)
        }
        
        let failureBlock = { (task: URLSessionDataTask?, error: Error) -> Void in
//            self.handleFailure(error)
        }
        
        self.manager.responseSerializer = AFHTTPResponseSerializer()
        self.manager.requestSerializer.setValue("", forHTTPHeaderField: "")
        self.request = self.manager.get(urlString, parameters: parameters, progress: nil, success: successBlock, failure: failureBlock)
    }
}






























