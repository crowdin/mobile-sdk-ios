//
//  BaseAPI.swift
//  BaseAPI
//
//  Created by Serhii Londar on 12/8/17.
//

import Foundation

public typealias BaseAPICompletion = (Data?, URLResponse?, Error?) -> Swift.Void
public typealias BaseAPIResult = SynchronousDataTaskResult
open class BaseAPI {
    var session: URLSession
    
    public init() {
        self.session = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func get(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, completion: @escaping BaseAPICompletion) {
        let request = Request(url: url, method: .GET, parameters: parameters, headers: headers, body: nil)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            let task = session.dataTask(with: urlRequest, completionHandler: completion)
            task.resume()
        } else {
            completion(nil, nil, buildRequest.error)
        }
    }
    
    public func get(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil) -> BaseAPIResult {
        let request = Request(url: url, method: .GET, parameters: parameters, headers: headers, body: nil)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            return session.synchronousDataTask(request: urlRequest)
        } else {
            return (nil, nil, buildRequest.error)
        }
    }
    
    public func head(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, completion: @escaping BaseAPICompletion) {
        let request = Request(url: url, method: .HEAD, parameters: parameters, headers: headers, body: nil)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            let task = session.dataTask(with: urlRequest, completionHandler: completion)
            task.resume()
        } else {
            completion(nil, nil, buildRequest.error)
        }
    }
    
    public func head(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil) -> BaseAPIResult {
        let request = Request(url: url, method: .HEAD, parameters: parameters, headers: headers, body: nil)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            return session.synchronousDataTask(request: urlRequest)
        } else {
            return (nil, nil, buildRequest.error)
        }
    }
    
    public func post(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, body: Data?, completion: @escaping BaseAPICompletion) {
        let request = Request(url: url, method: .POST, parameters: parameters, headers: headers, body: body)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            let task = session.dataTask(with: urlRequest, completionHandler: completion)
            task.resume()
        } else {
            completion(nil, nil, buildRequest.error)
        }
    }
    
    public func post(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, body: Data?) -> BaseAPIResult {
        let request = Request(url: url, method: .POST, parameters: parameters, headers: headers, body: body)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            return session.synchronousDataTask(request: urlRequest)
        } else {
            return (nil, nil, buildRequest.error)
        }
    }
    
    
    public func patch(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, body: Data?, completion: @escaping BaseAPICompletion) {
        let request = Request(url: url, method: .PATCH, parameters: parameters, headers: headers, body: body)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            let task = session.dataTask(with: urlRequest, completionHandler: completion)
            task.resume()
        } else {
            completion(nil, nil, buildRequest.error)
        }
    }
    
    public func patch(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, body: Data?) -> BaseAPIResult {
        let request = Request(url: url, method: .PATCH, parameters: parameters, headers: headers, body: body)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            return session.synchronousDataTask(request: urlRequest)
        } else {
            return (nil, nil, buildRequest.error)
        }
    }
    
    
    public func put(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, body: Data?, completion: @escaping BaseAPICompletion) {
        let request = Request(url: url, method: .PUT, parameters: parameters, headers: headers, body: body)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            let task = session.dataTask(with: urlRequest, completionHandler: completion)
            task.resume()
        } else {
            completion(nil, nil, buildRequest.error)
        }
    }
    
    public func put(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, body: Data?) -> BaseAPIResult {
        let request = Request(url: url, method: .PUT, parameters: parameters, headers: headers, body: body)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            return session.synchronousDataTask(request: urlRequest)
        } else {
            return (nil, nil, buildRequest.error)
        }
    }
    
    public func delete(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, body: Data? = nil, completion: @escaping BaseAPICompletion) {
        let request = Request(url: url, method: .DELETE, parameters: parameters, headers: headers, body: body)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            let task = session.dataTask(with: urlRequest, completionHandler: completion)
            task.resume()
        } else {
            completion(nil, nil, buildRequest.error)
        }
    }
    
    
    public func delete(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, body: Data? = nil) -> BaseAPIResult {
        let request = Request(url: url, method: .DELETE, parameters: parameters, headers: headers, body: body)
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            return session.synchronousDataTask(request: urlRequest)
        } else {
            return (nil, nil, buildRequest.error)
        }
    }
}
