//
//  CrowdinAPI.swift
//  CrowdinAPI
//
//  Created by Serhii Londar on 3/16/19.
//

import Foundation

public class CrowdinAPI: BaseAPI {
    let baseAPIPath = "https://api.crowdin.com/api"
    
    var apiPath: String {
        return ""
    }
    
    public func cw_post<T: Decodable>(url: String, parameters: [String: String]? = nil, headers: [String: String]? = nil, body: Data?, completion: @escaping (T?, Error?) -> Swift.Void) {
        self.post(url: url, parameters: parameters, headers: headers, body: body, completion: { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
                let response = try JSONDecoder().decode(T.self, from: data)
                completion(response, error)
            } catch {
                completion(nil, error)
            }
        })
    }
    
    public func cw_post<T: Decodable>(url: String, parameters: [String: String]? = nil, headers: [String: String]? = nil, body: Data?) -> (T?, Error?) {
        let result = self.post(url: url, parameters: parameters, headers: headers, body: body)
        guard let data = result.data else {
            return (nil, result.error)
        }
        do {
            let response = try JSONDecoder().decode(T.self, from: data)
            return (response, result.error)
        } catch {
            return (nil, error)
        }
    }
    
    public func cw_get<T: Decodable>(url: String, parameters: [String: String]? = nil, completion: @escaping (T?, Error?) -> Swift.Void) {
        self.get(url: url, parameters: parameters, completion: { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
                let response = try JSONDecoder().decode(T.self, from: data)
                completion(response, error)
            } catch {
                completion(nil, error)
            }
        })
    }
    
    public func cw_get<T: Decodable>(url: String, parameters: [String: String]? = nil) -> (T?, Error?) {
        let result = self.get(url: url, parameters: parameters)
        guard let data = result.data else {
            return (nil, result.error)
        }
        do {
            let response = try JSONDecoder().decode(T.self, from: data)
            return (response, result.error)
        } catch {
            return (nil, error)
        }
    }
}
