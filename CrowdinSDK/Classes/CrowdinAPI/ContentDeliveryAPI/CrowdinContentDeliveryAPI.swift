//
//  CrowdinContentDeliveryAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/18/19.
//

import Foundation
import BaseAPI

enum CrowdinContentDeliveryAPIError: Error {
    case badUrl(url: String)
    case parsingError(filePath: String)
    case dataError
    case error(error: Error?)
}

typealias CrowdinAPIStringsResult = (strings: [String: String]?, error: CrowdinContentDeliveryAPIError?)
typealias CrowdinAPIPluralsResult = (plurals: [AnyHashable: Any]?, error: CrowdinContentDeliveryAPIError?)
typealias CrowdinAPIFilesResult = (files: [String]?, error: CrowdinContentDeliveryAPIError?)

typealias CrowdinAPIStringsCompletion = (([String: String]?, CrowdinContentDeliveryAPIError?) -> Void)
typealias CrowdinAPIPluralsCompletion = (([AnyHashable: Any]?, CrowdinContentDeliveryAPIError?) -> Void)
typealias CrowdinAPIFilesCompletion = (([String]?, CrowdinContentDeliveryAPIError?) -> Void)

protocol CrowdinContentDeliveryProtolol {
    func getPlurals(filePath: String, completion: @escaping CrowdinAPIPluralsCompletion)
    func getStrings(filePath: String, completion: @escaping CrowdinAPIStringsCompletion)
}

class CrowdinContentDeliveryAPI: BaseAPI, CrowdinContentDeliveryProtolol {
    fileprivate enum FileType: String {
        case content
        case mapping
        case manifest
    }
    
    fileprivate enum Strings: String {
        case etag = "Etag"
        case ifNoneMatch = "If-None-Match"
    }
    
    private typealias CrowdinAPIDataCompletion = ((Data?, CrowdinContentDeliveryAPIError?) -> Void)
    
    private let hash: String
//    private let baseURL = "https://crowdin-distribution.s3.us-east-1.amazonaws.com"
//    private let baseURL = "https://production-enterprise-distribution.s3.us-east-1.amazonaws.com"
    private let baseURL = "https://distributions.crowdin.net"
    
    init(hash: String, session: URLSession) {
        self.hash = hash
        super.init(session: session)
    }
    
    init(hash: String) {
        self.hash = hash
        super.init(session: URLSession.shared)
    }
    
    private func buildURL(fileType: FileType, filePath: String) -> String {
        return baseURL + "/" + hash + "/" + fileType.rawValue + filePath
    }
    
    // MARK - General download methods
    
    private func get(filePath: String, completion: @escaping CrowdinAPIDataCompletion) {
        let stringURL = buildURL(fileType: .content, filePath: filePath)
        super.get(url: stringURL) { (data, _, error) in
            completion(data, CrowdinContentDeliveryAPIError.error(error: error))
        }
    }
    
    private func getFileSync(fileType: FileType, filePath: String) -> (data: Data?, error: CrowdinContentDeliveryAPIError?) {
        let stringURL = buildURL(fileType: fileType, filePath: filePath)
        let response = self.get(url: stringURL, parameters: nil, headers: nil)
        if let httpURLResponse = response.response as? HTTPURLResponse {
            let etag = httpURLResponse.allHeaderFields[Strings.etag.rawValue]
            UserDefaults.standard.setValue(etag, forKey: filePath)
            UserDefaults.standard.synchronize()
        }
        if let error = response.error {
            return (response.data, CrowdinContentDeliveryAPIError.error(error: error))
        } else {
            return (response.data, nil)
        }
    }
    
    // MARK - Localization and mapping download methods:
    
    // MARK - Localization download methods:
    
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
    
    // MARK: - Localization downloading sync methods
    
    func checkFileSync(filePath: String) -> Bool {
        let stringURL = buildURL(fileType: .content, filePath: filePath)
        if let etag = UserDefaults.standard.string(forKey: filePath) {
            let response = self.get(url: stringURL, parameters: nil, headers: [Strings.ifNoneMatch.rawValue: etag])
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
            let response = self.getFileSync(fileType: .content, filePath: filePath)
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
            let response = self.getFileSync(fileType: .content, filePath: filePath)
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
    
    // MARK - Mapping sync downloading methods
    func getStringsMappingSync(filePath: String) -> CrowdinAPIStringsResult {
        let response = self.getFileSync(fileType: .mapping, filePath: filePath)
        guard let data = response.data else {
            return (nil, CrowdinContentDeliveryAPIError.dataError)
        }
        guard let dictionary = CrowdinContentDelivery.parse(data: data) else {
            return (nil, CrowdinContentDeliveryAPIError.parsingError(filePath: filePath))
        }
        return (dictionary as? [String: String], nil)
    }
    
    func getPluralsMappingSync(filePath: String) -> CrowdinAPIPluralsResult {
        let response = self.getFileSync(fileType: .mapping, filePath: filePath)
        guard let data = response.data else {
            return (nil, CrowdinContentDeliveryAPIError.dataError)
        }
        guard let dictionary = CrowdinContentDelivery.parse(data: data) else {
            return (nil, CrowdinContentDeliveryAPIError.parsingError(filePath: filePath))
        }
        return (dictionary, nil)
    }
    
    func getFiles(completion: @escaping CrowdinAPIFilesCompletion) {
        let stringURL = buildURL(fileType: .manifest, filePath: ".json")
        super.get(url: stringURL) { [weak self] (data, _, error) in
            guard self != nil else { return }
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(ManifestResponse.self, from: data)
                    completion(response.files, nil)
                } catch {
                    completion(nil, .error(error: error))
                }
            } else {
                completion(nil, .error(error: error))
            }
        }
    }
}
