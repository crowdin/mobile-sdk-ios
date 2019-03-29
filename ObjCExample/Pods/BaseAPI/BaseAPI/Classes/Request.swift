//
//  Request.swift
//  BaseAPI
//
//  Created by Serhii Londar on 1/5/18.
//

import Foundation

public class Request {
    public var url: String
    public var method: RequestMethod
    public var parameters: [String : String]?
    public var headers: [String : String]?
    public var body: Data?
    
    public init(url: String, method: RequestMethod, parameters: [String : String]? = nil, headers: [String : String]? = nil, body: Data? = nil) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.body = body
    }
    
    public func request() -> (request: URLRequest?, error: Error?) {
        let url = URL(string: self.urlWithParameters())
        if let url = url {
            var request = URLRequest(url: url)
            if let headers = headers {
                for headerKey in headers.keys {
                    request.addValue(headers[headerKey]!, forHTTPHeaderField: headerKey)
                }
            }
            request.httpMethod = method.rawValue
            request.httpBody = body
            return (request, nil)
        } else {
            return (nil, "Unable to create URL")
        }
    }
    
    func urlWithParameters() -> String {
        var retUrl = url
        if let parameters = parameters {
            if parameters.count > 0 {
                retUrl.append("?")
				parameters.keys.forEach {
					guard let value = parameters[$0] else { return }
					let escapedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.BaseAPI_URLQueryAllowedCharacterSet())
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
