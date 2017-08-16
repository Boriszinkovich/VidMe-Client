//
//  KeychainStorage.swift
//  VidMeClient
//
//  Created by User on 15.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import Foundation
import KeychainAccess

class KeyChainStorage : NSObject
{
    static let sharedInstance = KeyChainStorage()
    
    let keyChain = Keychain(service: Constants.serviceName)
    
    fileprivate struct Constants
    {
        static let serviceName = "com.VidMeAccounts"
        static let password = "password"
        static let login = "login"
        static let accessToken = "accessToken"
        static let tokenExpiredDate = "tokenExpiredDate"
    }
    
    func setAccessToken(accessToken: String)
    {
        keyChain[Constants.accessToken] = accessToken
    }
    
    func setTokenExpiredDate(expiredTokenDate: String)
    {
        keyChain[Constants.tokenExpiredDate] = expiredTokenDate
    }
    
    func setPassword(password: String)
    {
        keyChain[Constants.password] = password
    }
    
    func setLogin(login: String)
    {
        keyChain[Constants.login] = login
    }
    
    func getPassword() -> String?
    {
        return keyChain[Constants.password]
    }
    
    func getLogin() -> String?
    {
        return keyChain[Constants.login]
    }
    
    func getAccessToken() -> String?
    {
        return keyChain[Constants.accessToken]
    }
    
    func getTokenExpiredDate() -> String?
    {
        return keyChain[Constants.tokenExpiredDate]
    }
    
    func removeAll()
    {
        keyChain[Constants.password] = nil
        keyChain[Constants.login] = nil
        keyChain[Constants.tokenExpiredDate] = nil
        keyChain[Constants.accessToken] = nil
    }
}






































