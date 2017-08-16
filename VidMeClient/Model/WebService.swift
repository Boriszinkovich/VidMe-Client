//
//  WebService.swift
//  VidMeClient
//
//  Created by User on 12.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import Foundation

protocol AuthListener: NSObjectProtocol
{
    func authStarted()
    func authorizeFailed(error: Error)
    func authorizeSuccess(user: User)
}

class WebService: NSObject
{
    static let sharedInstance = WebService()
    private(set) public var user: User? = User.restoreFromStorage()
    weak var authListener: AuthListener?
    
    func getFeaturedList(offset: UInt, success: FeaturedRequestClosureSuccess?, failure: @escaping VMClosureFailure) -> VidMeRequest
    {
        return FeaturedRequest(offset: offset, success: success, failure: failure)
    }
    
    func getNewVideosList(offset: UInt, success: NewVideosRequestClosureSuccess?, failure: @escaping VMClosureFailure) -> VidMeRequest
    {
        return NewVideosRequest(offset: offset, success: success, failure: failure)
    }
    
    func getFeedVideosList(offset: UInt, success: FeedRequestClosureSuccess?, failure: @escaping VMClosureFailure) -> VidMeRequest?
    {
        if self.user == nil
        {
            return nil
        }
        return FeedRequest(offset: offset, accessToken: self.user!.accessToken, success: success, failure: failure)
    }
    
    func authUser(username: String, password: String) -> AuthCreateRequest
    {
        self.authListener?.authStarted()
        return AuthCreateRequest(password: password, login: username, success: { (token) in
            let user = User(accessToken: token, password: password,login: username)
            user.saveToStorage()
            self.user = user
            self.authListener?.authorizeSuccess(user: user)
        }, failure: { (error) in
            self.authListener?.authorizeFailed(error: error)
        })
    }
    
    func authUser(user: User) -> AuthCreateRequest
    {
        return self.authUser(username: user.login, password: user.password)
    }
}






























