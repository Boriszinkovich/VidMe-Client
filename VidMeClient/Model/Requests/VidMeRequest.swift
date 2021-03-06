//
//  VidMeRequest.swift
//  VidMeClient
//
//  Created by User on 12.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import UIKit
import AFNetworking

typealias VMClosureSuccess = () -> Void
typealias VMClosureFailure = (_ error: Error) -> Void

class VidMeRequest: NSObject
{
    
    static let host = "https://api.vid.me"
    static let appKey = "JJxeSOZp4SYkENl1CiZAxpunJwlwKPmb"
    static let appSecret = "pTCaoJYfReqGcFeViSIAuuUJueGUqrfMiEWrBYOp"
    var isCancelled = false
    var failure: VMClosureFailure?
    var manager: AFHTTPSessionManager!
    
    static var counter = 0
    
    init(failure: VMClosureFailure?)
    {
        super.init()
        self.failure = failure
        
        let sessionConfiguration: URLSessionConfiguration? = URLSessionConfiguration.background(withIdentifier: "\(VidMeRequest.counter)")
        VidMeRequest.counter += 1
        sessionConfiguration?.timeoutIntervalForRequest = 30
        self.manager = AFHTTPSessionManager(sessionConfiguration: sessionConfiguration)
    }
    
    func send()
    {
        
    }
    
    func handleFailure(_ inError: Error?)
    {
        var error = inError
        if error == nil
        {
            error = NSError(domain: "zby.VidMeClient", code: -1, userInfo: nil)
        }
        self.failure?(error!)
    }
    
    func cancel()
    {
        isCancelled = true
    }
}































