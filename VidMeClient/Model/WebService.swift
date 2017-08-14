//
//  WebService.swift
//  VidMeClient
//
//  Created by User on 12.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import Foundation

class WebService: NSObject
{
    static let sharedInstance = WebService()
    
    
    func getFeaturedList(offset: UInt, success: FeaturedRequestClosureSuccess?, failure: @escaping VMClosureFailure) -> VidMeRequest
    {
        return FeaturedRequest(offset: offset, success: success, failure: failure)
    }
    
    func getNewVideosList(offset: UInt, success: NewVideosRequestClosureSuccess?, failure: @escaping VMClosureFailure) -> VidMeRequest
    {
        return NewVideosRequest(offset: offset, success: success, failure: failure)
    }
    
    func authUser(username: String, password: String, success: AuthCreateRequestClosureSuccess?, failure: @escaping VMClosureFailure) -> VidMeRequest
    {
        return AuthCreateRequest(password: password, login: username, success:success, failure: failure)
    }
}
