//
//  CrowdinAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/18/19.
//

import Foundation

enum Errors: Error {
    case badUrl(url: String)
    case parsingError(file: String)
    case dataError
}

typealias CrowdinAPIStringsCompletion = (([String : String]?, Error?) -> Void)
typealias CrowdinAPIPluralsCompletion = (([AnyHashable : Any]?, Error?) -> Void)

protocol CrowdinAPIProtolol {
    func getPlurals(file: String, for localization: String, completion: @escaping CrowdinAPIPluralsCompletion)
    func getStrings(file: String, for localization: String, completion: @escaping CrowdinAPIStringsCompletion)
}

class CrowdinAPI: CrowdinAPIProtolol {
    private typealias CrowdinAPIDataCompletion = ((Data?, Error?) -> Void)
    
    private let hash: String
    private let baseURL = "https://crowdin-distribution.s3.us-east-1.amazonaws.com"
    private let session: URLSession
    
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
            completion(nil, Errors.badUrl(url: stringURL))
            return
        }
        let task = self.session.dataTask(with: url) { (data, response, error) in
            completion(data, error)
        }
        task.resume()
    }
    
    func getStrings(file: String, for localization: String, completion: @escaping CrowdinAPIStringsCompletion) {
        self.get(file: file, for: localization) { (data, error) in
            guard let data = data else {
                completion(nil, Errors.dataError)
                return
            }
            guard let dictionary = String(data: data, encoding: .utf8)?.propertyListFromStringsFileFormat() else {
                completion(nil, Errors.parsingError(file: file))
                return
            }
            completion(dictionary, nil)
        }
    }
    
    func getPlurals(file: String, for localization: String, completion: @escaping CrowdinAPIPluralsCompletion) {
        self.get(file: file, for: localization) { (data, error) in
            guard let data = data else {
                completion(nil, Errors.dataError)
                return
            }
            var propertyListForamat =  PropertyListSerialization.PropertyListFormat.xml
            guard let dictionary = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &propertyListForamat) as? [AnyHashable: Any] else {
                completion(nil, Errors.parsingError(file: file))
                return
            }
            completion(dictionary, nil)
        }
    }
}
