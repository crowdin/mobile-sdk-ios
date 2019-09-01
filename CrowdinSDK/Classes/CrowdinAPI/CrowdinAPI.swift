//
//  CrowdinAPI.swift
//  CrowdinAPI
//
//  Created by Serhii Londar on 3/16/19.
//

import Foundation

class CrowdinAPI: BaseAPI {
    let organizationName: String?
    var baseURL: String {
        if let organizationName = organizationName {
            return "https://\(organizationName).crowdin.com/api/v2/"
        }
        return "https://crowdin.com/api/v2/"
    }
    
    var apiPath: String {
        return .empty
    }
    
    var fullPath: String {
        return baseURL + apiPath
    }
    
    init(organizationName: String? = nil) {
        self.organizationName = organizationName
        super.init()
    }
    
    func cw_post<T: Decodable>(url: String, parameters: [String: String]? = nil, headers: [String: String]? = nil, body: Data?, completion: @escaping (T?, Error?) -> Swift.Void) {
        self.post(url: url, parameters: parameters, headers: authorized(headers), body: body, completion: { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
                let response = try JSONDecoder().decode(T.self, from: data)
                completion(response, error)
            } catch {
                print(String(data: data, encoding: .utf8) ?? "Data is empty")
                completion(nil, error)
            }
        })
    }
    
    func cw_post<T: Decodable>(url: String, parameters: [String: String]? = nil, headers: [String: String]? = nil, body: Data?) -> (T?, Error?) {
        let result = self.post(url: url, parameters: parameters, headers: authorized(headers), body: body)
        guard let data = result.data else {
            return (nil, result.error)
        }
        do {
            let response = try JSONDecoder().decode(T.self, from: data)
            return (response, result.error)
        } catch {
            print(String(data: data, encoding: .utf8) ?? "Data is empty")
            return (nil, error)
        }
    }
    
    func cw_get<T: Decodable>(url: String, parameters: [String: String]? = nil, headers: [String: String]? = nil, completion: @escaping (T?, Error?) -> Swift.Void) {
        self.get(url: url, parameters: parameters, headers: authorized(headers), completion: { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
                let response = try JSONDecoder().decode(T.self, from: data)
                completion(response, error)
            } catch {
                print(String(data: data, encoding: .utf8) ?? "Data is empty")
                completion(nil, error)
            }
        })
    }
    
    func cw_get<T: Decodable>(url: String, parameters: [String: String]? = nil, headers: [String: String]? = nil) -> (T?, Error?) {
        let result = self.get(url: url, parameters: parameters, headers: authorized(headers))
        guard let data = result.data else {
            return (nil, result.error)
        }
        do {
            let response = try JSONDecoder().decode(T.self, from: data)
            return (response, result.error)
        } catch {
            print(String(data: data, encoding: .utf8) ?? "Data is empty")
            return (nil, error)
        }
    }
    
    func authorized(_ headers: [String: String]?) -> [String: String] {
        var result = headers ?? [:]
        guard let accessToken = LoginFeature.shared?.accessToken else { return result }
        result["Authorization"] = "Bearer \(accessToken)"
        return result
    }
}
