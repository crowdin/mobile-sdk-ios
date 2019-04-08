//
//  CrowdinContentDeliveryAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/18/19.
//

import Foundation

enum CrowdinContentDeliveryAPIError: Error {
    case badUrl(url: String)
    case parsingError(file: String)
    case dataError
    case error(error: Error?)
}

typealias CrowdinAPIStringsResult = (strings: [String: String]?, error: CrowdinContentDeliveryAPIError?)
typealias CrowdinAPIPluralsResult = (plurapls: [AnyHashable: Any]?, error: CrowdinContentDeliveryAPIError?)

typealias CrowdinAPIStringsCompletion = (([String: String]?, CrowdinContentDeliveryAPIError?) -> Void)
typealias CrowdinAPIPluralsCompletion = (([AnyHashable: Any]?, CrowdinContentDeliveryAPIError?) -> Void)

protocol CrowdinContentDeliveryProtolol {
    func getPlurals(file: String, for localization: String, completion: @escaping CrowdinAPIPluralsCompletion)
    func getStrings(file: String, for localization: String, completion: @escaping CrowdinAPIStringsCompletion)
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
    
    private func buildURL(localization: String, file: String) -> String {
        return baseURL + String.pathDelimiter + hash + String.pathDelimiter + localization + String.pathDelimiter + file
    }
    
    private func get(file: String, for localization: String, completion: @escaping CrowdinAPIDataCompletion) {
        let stringURL = buildURL(localization: localization, file: file)
        super.get(url: stringURL) { (data, _, error) in
            completion(data, CrowdinContentDeliveryAPIError.error(error: error))
        }
    }
    
    func getStrings(file: String, for localization: String, completion: @escaping CrowdinAPIStringsCompletion) {
        self.get(file: file, for: localization) { (data, _) in
            guard let data = data else {
                completion(nil, CrowdinContentDeliveryAPIError.dataError)
                return
            }
            guard let dictionary = CrowdinContentDelivery.parse(data: data) else {
                completion(nil, CrowdinContentDeliveryAPIError.parsingError(file: file))
                return
            }
            completion(dictionary as? [String: String], nil)
        }
    }
    
    func getPlurals(file: String, for localization: String, completion: @escaping CrowdinAPIPluralsCompletion) {
        self.get(file: file, for: localization) { (data, _) in
            guard let data = data else {
                completion(nil, CrowdinContentDeliveryAPIError.dataError)
                return
            }
            guard let dictionary = CrowdinContentDelivery.parse(data: data) else {
                completion(nil, CrowdinContentDeliveryAPIError.parsingError(file: file))
                return
            }
            completion(dictionary, nil)
        }
    }
    
    // MARK: - Sync methods
    
    func getFileSync(file: String, for localization: String) -> (data: Data?, error: CrowdinContentDeliveryAPIError?) {
        let stringURL = buildURL(localization: localization, file: file)
        let response = self.get(url: stringURL, parameters: nil, headers: nil)
        if let httpURLResponse = response.response as? HTTPURLResponse {
            let etag = httpURLResponse.allHeaderFields["Etag"]
            UserDefaults.standard.setValue(etag, forKey: file)
            UserDefaults.standard.synchronize()
        }
        if let error = response.error {
            return (response.data, CrowdinContentDeliveryAPIError.error(error: error))
        } else {
            return (response.data, nil)
        }
    }
    
    func checkFileSync(file: String, for localization: String) -> Bool {
        let stringURL = buildURL(localization: localization, file: file)
        if let etag = UserDefaults.standard.string(forKey: file) {
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
    
    func getStringsSync(file: String, for localization: String) -> CrowdinAPIStringsResult {
        if self.checkFileSync(file: file, for: localization) {
            let response = self.getFileSync(file: file, for: localization)
            guard let data = response.data else {
                return (nil, CrowdinContentDeliveryAPIError.dataError)
            }
            guard let dictionary = CrowdinContentDelivery.parse(data: data) else {
                return (nil, CrowdinContentDeliveryAPIError.parsingError(file: file))
            }
            return (dictionary as? [String: String], nil)
        }
        return (nil, nil)
    }
    
    func getPluralsSync(file: String, for localization: String) -> CrowdinAPIPluralsResult {
        if self.checkFileSync(file: file, for: localization) {
            let response = self.getFileSync(file: file, for: localization)
            guard let data = response.data else {
                return (nil, CrowdinContentDeliveryAPIError.dataError)
            }
            guard let dictionary = CrowdinContentDelivery.parse(data: data) else {
                return (nil, CrowdinContentDeliveryAPIError.parsingError(file: file))
            }
            return (dictionary, nil)
        }
        return (nil, nil)
    }
}
