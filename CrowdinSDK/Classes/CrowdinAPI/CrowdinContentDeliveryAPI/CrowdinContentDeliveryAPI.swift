//
//  CrowdinContentDeliveryAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/18/19.
//

import Foundation

enum CrowdinContentDeliveryAPIError: Error {
    case badUrl(url: String)
    case parsingError(filePath: String)
    case dataError
    case error(error: Error?)
}

typealias CrowdinAPIStringsResult = (strings: [String: String]?, error: CrowdinContentDeliveryAPIError?)
typealias CrowdinAPIPluralsResult = (plurapls: [AnyHashable: Any]?, error: CrowdinContentDeliveryAPIError?)

typealias CrowdinAPIStringsCompletion = (([String: String]?, CrowdinContentDeliveryAPIError?) -> Void)
typealias CrowdinAPIPluralsCompletion = (([AnyHashable: Any]?, CrowdinContentDeliveryAPIError?) -> Void)

protocol CrowdinContentDeliveryProtolol {
    func getPlurals(filePath: String, completion: @escaping CrowdinAPIPluralsCompletion)
    func getStrings(filePath: String, completion: @escaping CrowdinAPIStringsCompletion)
}

class CrowdinContentDeliveryAPI: BaseAPI, CrowdinContentDeliveryProtolol {
    private typealias CrowdinAPIDataCompletion = ((Data?, CrowdinContentDeliveryAPIError?) -> Void)
    
    private let hash: String
    private let baseURL = "https://crowdin-distribution.s3.us-east-1.amazonaws.com"
    
    init(hash: String, session: URLSession) {
        self.hash = hash
        super.init(session: session)
    }
    
    init(hash: String) {
        self.hash = hash
        super.init(session: URLSession.shared)
    }
    
    private func buildURL(filePath: String) -> String {
        return baseURL + String.pathDelimiter + hash + filePath
    }
    
    private func get(filePath: String, completion: @escaping CrowdinAPIDataCompletion) {
        let stringURL = buildURL(filePath: filePath)
        super.get(url: stringURL) { (data, _, error) in
            completion(data, CrowdinContentDeliveryAPIError.error(error: error))
        }
    }
    
    func getStrings(filePath: String, completion: @escaping CrowdinAPIStringsCompletion) {
        self.get(filePath: filePath) { (data, _) in
            guard let data = data else {
                completion(nil, CrowdinContentDeliveryAPIError.dataError)
                return
            }
            guard let dictionary = CrowdinContentDelivery.parse(data: data) else {
                completion(nil, CrowdinContentDeliveryAPIError.parsingError(filePath: filePath))
                return
            }
            completion(dictionary as? [String: String], nil)
        }
    }
    
    func getPlurals(filePath: String, completion: @escaping CrowdinAPIPluralsCompletion) {
        self.get(filePath: filePath) { (data, _) in
            guard let data = data else {
                completion(nil, CrowdinContentDeliveryAPIError.dataError)
                return
            }
            guard let dictionary = CrowdinContentDelivery.parse(data: data) else {
                completion(nil, CrowdinContentDeliveryAPIError.parsingError(filePath: filePath))
                return
            }
            completion(dictionary, nil)
        }
    }
    
    // MARK: - Sync methods
    
    func getFileSync(filePath: String) -> (data: Data?, error: CrowdinContentDeliveryAPIError?) {
        let stringURL = buildURL(filePath: filePath)
        let response = self.get(url: stringURL, parameters: nil, headers: nil)
        if let httpURLResponse = response.response as? HTTPURLResponse {
            let etag = httpURLResponse.allHeaderFields["Etag"]
            UserDefaults.standard.setValue(etag, forKey: filePath)
            UserDefaults.standard.synchronize()
        }
        if let error = response.error {
            return (response.data, CrowdinContentDeliveryAPIError.error(error: error))
        } else {
            return (response.data, nil)
        }
    }
    
    func checkFileSync(filePath: String) -> Bool {
        let stringURL = buildURL(filePath: filePath)
        if let etag = UserDefaults.standard.string(forKey: filePath) {
            let response = self.get(url: stringURL, parameters: nil, headers: ["If-None-Match": etag])
            var download = true
            if let httpURLResponse = response.response as? HTTPURLResponse {
                download = httpURLResponse.statusCode != 304
            }
            return download
        } else {
            return true
        }
    }
    
    func getStringsSync(filePath: String) -> CrowdinAPIStringsResult {
        if self.checkFileSync(filePath: filePath) {
            let response = self.getFileSync(filePath: filePath)
            guard let data = response.data else {
                return (nil, CrowdinContentDeliveryAPIError.dataError)
            }
            guard let dictionary = CrowdinContentDelivery.parse(data: data) else {
                return (nil, CrowdinContentDeliveryAPIError.parsingError(filePath: filePath))
            }
            return (dictionary as? [String: String], nil)
        }
        return (nil, nil)
    }
    
    func getPluralsSync(filePath: String) -> CrowdinAPIPluralsResult {
        if self.checkFileSync(filePath: filePath) {
            let response = self.getFileSync(filePath: filePath)
            guard let data = response.data else {
                return (nil, CrowdinContentDeliveryAPIError.dataError)
            }
            guard let dictionary = CrowdinContentDelivery.parse(data: data) else {
                return (nil, CrowdinContentDeliveryAPIError.parsingError(filePath: filePath))
            }
            return (dictionary, nil)
        }
        return (nil, nil)
    }
}
