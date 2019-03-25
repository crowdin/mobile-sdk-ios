//
//  CrowdinAPI.swift
//  CrowdinAPI
//
//  Created by Serhii Londar on 3/16/19.
//

import Foundation
import BaseAPI

public class CrowdinAPI: BaseAPI {
    let baseAPIPath = "https://api.crowdin.com/api"
    
    var apiPath: String {
        return ""
    }
    
    func jsonDataFrom(xmlData: Data) -> Data? {
        guard let dictionary = XMLDictionaryParser().dictionaryWithData(data: xmlData) else {
            return nil
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return nil
        }
        return jsonData
    }
    
    
    public func post<T:Decodable>(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, body: Data?, completion: @escaping (T?, Error?) -> Swift.Void) {
        self.post(url: url, parameters: parameters, headers: headers, body: body, completion: { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            guard let jsonData = self.jsonDataFrom(xmlData: data) else {
                completion(nil, error)
                return
            }
            do {
                let response = try JSONDecoder().decode(T.self, from: jsonData)
                completion(response, error)
            } catch {
                completion(nil, error)
            }
        })
    }
    
    public func post<T:Decodable>(url: String, parameters: [String : String]? = nil, headers: [String: String]? = nil, body: Data?) -> (T?, Error?) {
        let result = self.post(url: url, parameters: parameters, headers: headers, body: body)
        guard let data = result.data else {
            return (nil, result.error)
        }
        guard let jsonData = self.jsonDataFrom(xmlData: data) else {
            return (nil, result.error)
        }
        do {
            let response = try JSONDecoder().decode(T.self, from: jsonData)
            return (response, result.error)
        } catch {
            return (nil, error)
        }
    }
}

