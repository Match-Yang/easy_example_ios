//
//  FcmTokenRequest.swift
//  ZegoEasyExample
//
//  Created by zego on 2022/5/12.
//

import UIKit

struct FcmTokenRequest: Request {
    var path = "/store_fcm_token"
    var method: HTTPMethod = .POST
    typealias Response = RequestStatus
    var parameter = Dictionary<String, AnyObject>()
    
    var userID = "" {
        willSet {
            parameter["userID"] = newValue as AnyObject
        }
    }
    
    var token = "" {
        willSet {
            parameter["token"] = newValue as AnyObject
        }
    }
    
    init() {
        
    }
}
