//
//  CallUserRequest.swift
//  ZegoEasyExample
//
//  Created by zego on 2022/5/12.
//

import UIKit

struct CallUserRequest: Request {
    var path = "/call_invite"
    var method: HTTPMethod = .POST
    typealias Response = RequestStatus
    var parameter = Dictionary<String, AnyObject>()
    
    var targetUserID = "" {
        willSet {
            parameter["targetUserID"] = newValue as AnyObject
        }
    }
    
    var callerUserID = "" {
        willSet {
            parameter["callerUserID"] = newValue as AnyObject
        }
    }
    
    var callerUserName = "" {
        willSet {
            parameter["callerUserName"] = newValue as AnyObject
        }
    }
    
    var callerIconUrl = "" {
        willSet {
            parameter["callerIconUrl"] = newValue as AnyObject
        }
    }
    
    var roomID = "" {
        willSet {
            parameter["roomID"] = newValue as AnyObject
        }
    }
    
    var callType = "" {
        willSet {
            parameter["callType"] = newValue as AnyObject
        }
    }
    
    init() {
        
    }
}
