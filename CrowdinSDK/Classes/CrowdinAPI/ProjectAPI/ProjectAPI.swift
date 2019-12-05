//
//  ProjectAPI.swift
//  BaseAPI
//
//  Created by Serhii Londar on 3/21/19.
//

import Foundation

class ProjectAPI: CrowdinAPI {
    enum Strings: String {
        case project
        case key
        case json
        case info
    }
    
    override var apiPath: String { return Strings.project.rawValue }

    var projectKey: String
    var projectIdentifier: String
    
    init(projectIdentifier: String, projectKey: String) {
        self.projectIdentifier = projectIdentifier
        self.projectKey = projectKey
        super.init()
    }
    
    override var fullPath: String {
        return "\(baseURL)/\(apiPath)/\(projectIdentifier)/"
    }
    
    func buildParameters(with parameters: [String: String]? = nil) -> [String: String] {
        var resultParameters = [Strings.key.rawValue : projectKey]
        resultParameters[Strings.json.rawValue] = ""
        if let parameters = parameters {
            parameters.forEach({ resultParameters[$0.key] = $0.value })
        }
        return resultParameters
    }
    
    func projectDetails(completion: @escaping (ProjectDetailsResponse?, Error?) -> Void) {
        let method = Strings.info.rawValue
        let url = "\(fullPath)\(method)/"
        self.cw_post(url: url, parameters: self.buildParameters(), headers: nil, body: nil, completion: completion)
    }
    
    func projectDetailsSync() -> (ProjectDetailsResponse?, Error?) {
        let method = Strings.info.rawValue
        let url = "\(fullPath)\(method)/"
        return self.cw_post(url: url, parameters: self.buildParameters(), headers: nil, body: nil)
    }
}
