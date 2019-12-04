//
//  Request.swift
//  BaseAPI
//
//  Created by Serhii Londar on 1/5/18.
//

import Foundation

class Request {
    fileprivate let defaultCrowdinErrorCode = 9999
    var url: String
    var method: RequestMethod
    var parameters: [String: String]?
    var headers: [String: String]?
    var body: Data?
    
    init(url: String, method: RequestMethod, parameters: [String: String]? = nil, headers: [String: String]? = nil, body: Data? = nil) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.body = body
    }
    
    func request() -> (request: URLRequest?, error: Error?) {
        let url = URL(string: self.urlWithParameters())
        if let url = url {
            var request = URLRequest(url: url)
            if let headers = headers {
                for (key, value) in headers {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
            request.httpMethod = method.rawValue
            request.httpBody = body
            return (request, nil)
        } else {
            return (nil, NSError(domain:"Unable to create URL", code:defaultCrowdinErrorCode, userInfo:nil) )
        }
    }
    
    func urlWithParameters() -> String {
        var retUrl = url
        if let parameters = parameters {
            if parameters.count > 0 {
                retUrl.append("?")
				parameters.keys.forEach {
					guard let value = parameters[$0] else { return }
					let escapedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.ba_URLQueryAllowedCharacterSet())
					if let escapedValue = escapedValue {
						retUrl.append("\($0)=\(escapedValue)&")
					}
				}
                retUrl.removeLast()
            }
        }
        return retUrl
    }
}
