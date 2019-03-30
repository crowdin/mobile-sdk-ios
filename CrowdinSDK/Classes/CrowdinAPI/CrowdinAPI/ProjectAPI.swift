//
//  ProjectAPI.swift
//  BaseAPI
//
//  Created by Serhii Londar on 3/21/19.
//

import Foundation

public class ProjectAPI: CrowdinAPI {
    override var apiPath: String { return "project" }

    var projectKey: String
    var projectIdentifier: String
    
    public init(projectIdentifier: String, projectKey: String) {
        self.projectIdentifier = projectIdentifier
        self.projectKey = projectKey
        super.init()
    }
    
    func buildURL(method: String) -> String {
        return "\(baseAPIPath)/\(apiPath)/\(projectIdentifier)/\(method)/"
    }
    
    func buildParameters(with parameters: [String: String]? = nil) -> [String: String] {
        var resultParameters = ["key" : projectKey]
        resultParameters["json"] = ""
        if let parameters = parameters {
            parameters.forEach({ resultParameters[$0.key] = $0.value })
        }
        return resultParameters
    }
    
    public func projectDetails(completion: @escaping (ProjectDetailsResponse?, Error?) -> Void) {
        let method = "info"
        let url = self.buildURL(method: method)
        self.cw_post(url: url, parameters: self.buildParameters(), headers: nil, body: nil, completion: completion)
    }
    
    public func projectDetailsSync() -> (ProjectDetailsResponse?, Error?) {
        let method = "info"
        let url = self.buildURL(method: method)
        return self.cw_post(url: url, parameters: self.buildParameters(), headers: nil, body: nil)
    }
}
