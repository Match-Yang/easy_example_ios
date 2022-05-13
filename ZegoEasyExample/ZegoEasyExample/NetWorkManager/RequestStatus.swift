//
//  RequestStatus.swift
//  ZEGOLiveDemo
//
//  Created by Larry on 2021/12/27.
//

import Foundation

struct RequestStatus {
    var ret = 0
    var message = ""
    var data = Dictionary<String, AnyObject>()
    
    init(json: Dictionary<String, Any>) {
        ret = json["ret"] as? Int ?? 0
        message = json["message"] as? String ?? ""
        
        if let dataDic = json["data"] as? Dictionary<String, AnyObject>  {
            data = dataDic
        } else if let dataDic = json["Data"] as? Dictionary<String, AnyObject> {
            data = dataDic
        }
    }
}

extension RequestStatus: Decodable {
    static func parse(_ json: Dictionary<String, Any>) -> RequestStatus? {
        return RequestStatus(json: json)
    }
}
