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

class CrowdinAPI {
    let hash: String
    let baseURL = "https://crowdin-distribution.s3.us-east-1.amazonaws.com"
    let session: URLSession
    
    init(hash: String) {
        self.hash = hash
        session = URLSession.shared
    }
    
    func buildURL(localization: String, file: String) -> String {
        return baseURL + "/" + hash + "/" + localization + "/" + file
    }
    
    func get(file: String, for localization: String, completion: @escaping ((Data?, Error?) -> Void)) {
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
    
    func getStrings(file: String, for localization: String, completion: @escaping (([String : String]?, Error?) -> Void)) {
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
    
    func getPlurals(file: String, for localization: String, completion: @escaping (([AnyHashable : Any]?, Error?) -> Void)) {
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
    
    // TODO:
    func getSync(file: String, for localization: String) {
        
    }
}
