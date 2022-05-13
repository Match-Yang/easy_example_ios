//
//  NetworkManager.swift
//  ZEGOLiveDemo
//
//  Created by Larry on 2021/12/27.
//

import Foundation

class NetworkManager: NSObject, RequestSender {
    static let shareManage: NetworkManager = NetworkManager()
    lazy var session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue())
    }()
    
    /// Get and Post request
    func send<T: Request>(_ req: T, handler: @escaping (T.Response?) -> Void) {
        var hostPath = host
        if let coustomHost = req.parameter["host"] as? String {
            hostPath = coustomHost
        }
        let url = URL(string: hostPath.appending(req.path))!
        var request = URLRequest(url: url)
        
        request.httpMethod = req.method.rawValue
        var parameterDic = self.mergeParameter(req)
        parameterDic.removeValue(forKey: "host")
        func handleParameters() {
            if needEncodesParametersForMethod(method: req.method) {
                guard let URL = request.url else {
                    print("Invalid URL of request: \(request)")
                    return
                }
                if let URLComponents = NSURLComponents(url: URL, resolvingAgainstBaseURL: false) {
                    URLComponents.percentEncodedQuery = (URLComponents.percentEncodedQuery != nil ? URLComponents.percentEncodedQuery! + "&" : "") + query(parameterDic)
                    request.url = URLComponents.url
                }
            } else {
                if let json = ZegoJsonTool.dictionaryToJson(parameterDic) {
                    let data = json.data(using: .utf8)
                    request.httpBody = data
                }
            }
        }
        handleParameters()
        
        for (key, value) in req.header {
            request.setValue(value, forHTTPHeaderField: key)
        }
        let task = session.dataTask(with: request, completionHandler:{(data, res, error) in
            guard let reponseData = data else { return }
            guard let responseDic = try? JSONSerialization.jsonObject(with: reponseData, options: .mutableContainers) as? [String : Any] else {
                return
            }
            guard let response = T.Response.parse(responseDic) else { return }
            
            DispatchQueue.main.async {
                handler(response)
            }
        })
        task.resume()
    }
    
    private func mergeParameter<T: Request>(_ req: T) -> Dictionary<String, AnyObject>{
        var tempDic = Dictionary<String, AnyObject>()
        for (key, value) in req.parameter{
            tempDic[key] = value as AnyObject
        }
        return tempDic
    }
    
    private func needEncodesParametersForMethod(method: HTTPMethod) -> Bool {
        switch method {
        case .GET:
            return true
        default:
            return false
        }
    }
    
    private func buildQuery(parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sorted(by: <) {
            if let value: AnyObject = parameters[key] {
                components += queryComponents(fromKey: key, value: value)
            }
        }
        return (components.map{"\($0)=\($1)"} as [String]).joined(separator: "&")
    }
    
    private func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        let escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        return escaped
    }
    
    public func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    private func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    private func paraMerge(_ parameters: [String: Any], value: [String: String]) -> [String: Any]{
        var components = [String: Any]()
        for (key, value) in value {
            components[key] = value
        }
        for (key, value) in parameters {
            components[key] = value
        }
        return components
    }
    
    
}

extension NetworkManager: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            var disposition = URLSession.AuthChallengeDisposition.performDefaultHandling

            var credential:URLCredential? = nil

            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

                if credential != nil {
                    disposition = URLSession.AuthChallengeDisposition.useCredential
                }
            } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
                disposition = URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge
            } else {
                disposition = URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge
            }
//        let disposition = URLSession.AuthChallengeDisposition.useCredential
//        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
//        return (disposition, credential)
            completionHandler(disposition, credential)
    }
}
                            

extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
                             
                             
