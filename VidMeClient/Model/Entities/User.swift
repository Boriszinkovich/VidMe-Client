//
//  User.swift
//  VidMeClient
//
//  Created by User on 15.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import Foundation

struct AccessToken
{
    let value: String
    let expiredDate: Date
}

extension AccessToken
{
    init(json: [String: Any]) throws
    {
        guard let expiredDateString = json["expires"] as? String,
            let token = json["token"] as? String
            else
        {
            throw NSError(domain: "", code: -1, userInfo: nil)
        }
        self.value = token
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateObj = dateFormatter.date(from: expiredDateString)
        if let dateObj = dateObj
        {
            self.expiredDate = dateObj
        }
        else
        {
            throw NSError(domain: "", code: -1, userInfo: nil)
        }
    }
    
    static func restoreFromStorage() -> AccessToken?
    {
        guard let value = KeyChainStorage.sharedInstance.getAccessToken(),
            let expiredValue = KeyChainStorage.sharedInstance.getTokenExpiredDate(),
            let expiredDoubleValue =  Double(expiredValue)
            else
        {
            return nil
        }
        let date = Date(timeIntervalSince1970:expiredDoubleValue)
        return AccessToken(value: value, expiredDate: date)
    }
    
    func saveToStorage()
    {
        KeyChainStorage.sharedInstance.setAccessToken(accessToken: self.value)
        KeyChainStorage.sharedInstance.setTokenExpiredDate(expiredTokenDate: String(format:"%.1f", self.expiredDate.timeIntervalSince1970))
    }
    
    func isValid() -> Bool
    {
        let currentDate = Date()
        return self.expiredDate.timeIntervalSince(currentDate) > 0
    }
}

struct User
{
    let password: String
    let login: String
    let accessToken: AccessToken
}

extension User
{
    init(accessToken: AccessToken, password: String, login: String)
    {
        self.accessToken = accessToken
        self.password = password
        self.login = login
    }
    
    static func restoreFromStorage() -> User?
    {
        guard let password = KeyChainStorage.sharedInstance.getPassword(),
            let login = KeyChainStorage.sharedInstance.getLogin(),
            let token =  AccessToken.restoreFromStorage()
            else
        {
            return nil
        }
        return User(accessToken: token, password: password, login: login)
    }
    func saveToStorage()
    {
        accessToken.saveToStorage()
        KeyChainStorage.sharedInstance.setPassword(password: self.password)
        KeyChainStorage.sharedInstance.setLogin(login: self.login)
    }
}





























