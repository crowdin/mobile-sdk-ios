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

class CrowdinContentDeliveryAPI: CrowdinContentDeliveryProtolol {
    private typealias CrowdinAPIDataCompletion = ((Data?, CrowdinContentDeliveryAPIError?) -> Void)
    
    private let hash: String
    private let baseURL = "https://crowdin-distribution.s3.us-east-1.amazonaws.com"
    private let session: URLSession
    
    init(hash: String, session: URLSession) {
        self.hash = hash
        self.session = session
    }
    
    init(hash: String) {
        self.hash = hash
        session = URLSession.shared
    }
    
    private func buildURL(localization: String, file: String) -> String {
        return baseURL + String.pathDelimiter + hash + String.pathDelimiter + localization + String.pathDelimiter + file
    }
    
    private func get(file: String, for localization: String, completion: @escaping CrowdinAPIDataCompletion) {
        let stringURL = buildURL(localization: localization, file: file)
        guard let url = URL(string: stringURL) else {
            completion(nil, CrowdinContentDeliveryAPIError.badUrl(url: stringURL))
            return
        }
        let task = self.session.dataTask(with: url) { (data, _, error) in
            completion(data, CrowdinContentDeliveryAPIError.error(error: error))
        }
        task.resume()
    }
    
    func parse(data: Data) -> [AnyHashable: Any]? {
        var propertyListForamat = PropertyListSerialization.PropertyListFormat.xml
        guard let dictionary = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &propertyListForamat) as? [AnyHashable: Any] else {
            return nil
        }
        return dictionary
    }
    
    private func getSync(file: String, for localization: String, completion: @escaping CrowdinAPIDataCompletion) {
        let stringURL = buildURL(localization: localization, file: file)
        guard let url = URL(string: stringURL) else {
            completion(nil, CrowdinContentDeliveryAPIError.badUrl(url: stringURL))
            return
        }
        let task = self.session.dataTask(with: url) { (data, _, error) in
            completion(data, CrowdinContentDeliveryAPIError.error(error: error))
        }
        task.resume()
    }
    
    func getStrings(file: String, for localization: String, completion: @escaping CrowdinAPIStringsCompletion) {
        self.get(file: file, for: localization) { (data, _) in
            guard let data = data else {
                completion(nil, CrowdinContentDeliveryAPIError.dataError)
                return
            }
            guard let dictionary = self.parse(data: data) else {
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
            guard let dictionary = self.parse(data: data) else {
                completion(nil, CrowdinContentDeliveryAPIError.parsingError(file: file))
                return
            }
            completion(dictionary, nil)
        }
    }
    
    // MARK: - Sync methods
    
    func getSync(file: String, for localization: String) -> (data: Data?, error: CrowdinContentDeliveryAPIError?) {
        let stringURL = buildURL(localization: localization, file: file)
        guard let url = URL(string: stringURL) else {
            return (nil, CrowdinContentDeliveryAPIError.badUrl(url: stringURL))
        }
        let response = self.session.synchronousDataTask(url: url)
        return (response.data, CrowdinContentDeliveryAPIError.error(error: response.error))
    }
    
    func getStrings(file: String, for localization: String) -> CrowdinAPIStringsResult {
        let response = self.getSync(file: file, for: localization)
        guard let data = response.data else {
            return (nil, CrowdinContentDeliveryAPIError.dataError)
        }
        guard let dictionary = self.parse(data: data) else {
            return (nil, CrowdinContentDeliveryAPIError.parsingError(file: file))
        }
        return (dictionary as? [String: String], nil)
    }
    
    func getPlurals(file: String, for localization: String) -> CrowdinAPIPluralsResult {
        let response = self.getSync(file: file, for: localization)
        guard let data = response.data else {
            return (nil, CrowdinContentDeliveryAPIError.dataError)
        }
        guard let dictionary = self.parse(data: data) else {
            return (nil, CrowdinContentDeliveryAPIError.parsingError(file: file))
        }
        return (dictionary, nil)
    }
}
