//
//  CrowdinContentDeliveryAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/18/19.
//

import Foundation
import BaseAPI

typealias CrowdinAPIStringsCompletion = (([String: String]?, String?, Error?) -> Void)
typealias CrowdinAPIPluralsCompletion = (([AnyHashable: Any]?, String?, Error?) -> Void)
typealias CrowdinAPIStringsMappingCompletion = (([String: String]?, Error?) -> Void)
typealias CrowdinAPIPluralsMappingCompletion = (([AnyHashable: Any]?, Error?) -> Void)

typealias CrowdinAPIManifestCompletion = ((ManifestResponse?, Error?) -> Void)

class CrowdinContentDeliveryAPI: BaseAPI {
    enum FileType: String {
        case content
        case mapping
        case manifest
    }
    
    fileprivate enum Strings: String {
        case etag = "Etag"
        case ifNoneMatch = "If-None-Match"
    }
    
    private typealias CrowdinAPIDataCompletion = ((Data?, URLResponse?, Error?) -> Void)
    
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
    
    private func buildURL(fileType: FileType, filePath: String, timestamp: TimeInterval?) -> String {
        if let timestamp = timestamp {
            return "\(baseURL)/\(hash)/\(fileType.rawValue)\(filePath)?timestamp=\(String(timestamp))"
        } else {
            return "\(baseURL)/\(hash)/\(fileType.rawValue)\(filePath)"
        }
    }
    
    // MARK - General download methods
    private func getFile(fileType: FileType, filePath: String, etag: String?, timestamp: TimeInterval?, completion: @escaping CrowdinAPIDataCompletion) {
        let stringURL = buildURL(fileType: fileType, filePath: filePath, timestamp: timestamp)
        var headers: [String: String] = [:]
        if let etag = etag {
            headers = [Strings.ifNoneMatch.rawValue: etag]
        }
        super.get(url: stringURL, headers: headers, completion: completion)
    }
    
    // MARK - Localization download methods:
    func getStrings(filePath: String, etag: String?, timestamp: TimeInterval?, completion: @escaping CrowdinAPIStringsCompletion) {
        self.getFile(fileType: .content, filePath: filePath, etag: etag, timestamp: timestamp) { (data, response, error) in
            let etag = (response as? HTTPURLResponse)?.allHeaderFields[Strings.etag.rawValue] as? String
            if let data = data {
                guard let dictionary = CrowdinContentDelivery.parse(data: data) else {
                    completion(nil, etag, error)
                    return
                }
                completion(dictionary as? [String: String], etag, nil)
            } else {
                completion(nil, etag, error)
            }
        }
    }
    
    func getPlurals(filePath: String, etag: String?, timestamp: TimeInterval?, completion: @escaping CrowdinAPIPluralsCompletion) {
        self.getFile(fileType: .content, filePath: filePath, etag: etag, timestamp: timestamp) { (data, response, error) in
            let etag = (response as? HTTPURLResponse)?.allHeaderFields[Strings.etag.rawValue] as? String
            if let data = data {
                guard let dictionary = CrowdinContentDelivery.parse(data: data) else {
                    completion(nil, etag, error)
                    return
                }
                completion(dictionary, etag, nil)
            } else {
                completion(nil, etag, error)
            }
        }
    }
    
    // MARK - Mapping download methods:
    func getStringsMapping(filePath: String, etag: String?, timestamp: TimeInterval?, completion: @escaping CrowdinAPIStringsMappingCompletion) {
        self.getFile(fileType: .mapping, filePath: filePath, etag: etag, timestamp: timestamp) { (data, _, error) in
            if let data = data {
                guard let dictionary = CrowdinContentDelivery.parse(data: data) else {
                    completion(nil, error)
                    return
                }
                completion(dictionary as? [String: String], nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getPluralsMapping(filePath: String, etag: String?, timestamp: TimeInterval?, completion: @escaping CrowdinAPIPluralsMappingCompletion) {
        self.getFile(fileType: .mapping, filePath: filePath, etag: etag, timestamp: timestamp) { (data, _, error) in
            if let data = data {
                guard let dictionary = CrowdinContentDelivery.parse(data: data) else {
                    completion(nil, error)
                    return
                }
                completion(dictionary, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getManifest(completion: @escaping CrowdinAPIManifestCompletion) {
        let stringURL = buildURL(fileType: .manifest, filePath: ".json", timestamp: nil)
        super.get(url: stringURL) { [weak self] (data, _, error) in
            guard self != nil else { return }
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(ManifestResponse.self, from: data)
                    completion(response, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getManifestSync() -> ManifestResponse? {
        let stringURL = buildURL(fileType: .manifest, filePath: ".json", timestamp: nil)
        let result = super.get(url: stringURL)
        if let data = result.data {
            do {
                let response = try JSONDecoder().decode(ManifestResponse.self, from: data)
                return response
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}
