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
        self.login = login
        self.password = password
        send()
    }
    
    
    override func send()
    {
        let urlString = VidMeRequest.host + "/auth/create"
        let parameters = ["username" : self.login, "password" : self.password]
        let successBlock = { (task: URLSessionDataTask, responseObject: Any?) -> Void in
            let jsonData = responseObject as? Data
            guard let data = jsonData,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else
            {
                self.handleFailure(nil)
                return
            }
            print(json)
        }
        
        let failureBlock = { (task: URLSessionDataTask?, error: Error) -> Void in
//            self.handleFailure(error)
            print(error.localizedDescription)
        }
        
        let str = VidMeRequest.appKey + ":" + VidMeRequest.appSecret
        self.manager.responseSerializer = AFHTTPResponseSerializer()
        let base64Encoded = Data(str.utf8).base64EncodedString()
            self.manager.requestSerializer.setValue("Basic " + base64Encoded, forHTTPHeaderField: "Authorization")
            self.request = self.manager.post(urlString, parameters: parameters, progress: nil, success: successBlock, failure: failureBlock)

    }
}






























