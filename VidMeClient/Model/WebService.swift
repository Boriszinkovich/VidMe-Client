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
    
    
    func featured(offset: UInt, success: FeaturedRequestClosureSuccess?, failure: @escaping VMClosureFailure) -> VidMeRequest
    {
        return FeaturedRequest(offset: offset, success: success, failure: failure)
    }
}
