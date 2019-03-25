//
//  Operations.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/25/19.
//

import Foundation

protocol DownloadProjectInfoOperationProtocol {
    var projectKey: String { get }
    var projectIdentifier: String { get }
}

class DownloadProjectInfoOperation: AsyncOperation, DownloadProjectInfoOperationProtocol {
    var completion: ((ProjectDetailsInfo?, Error?) -> Void)? = nil
    
    var error: Error?
    var projectDetails: ProjectDetailsInfo?
    
    var projectIdentifier: String
    var projectKey: String
    
    required init(projectIdentifier: String, projectKey: String) {
        self.projectIdentifier = projectIdentifier
        self.projectKey = projectKey
    }
    
    override func main() {
        let projectsAPI = ProjectAPI(projectIdentifier: projectIdentifier, projectKey: projectKey)
        let response = projectsAPI.projectDetailsSync()
        self.projectDetails = response.0
        self.error = response.1
        self.completion?(self.projectDetails, self.error)
        self.finish(with: self.error != nil)
    }
}
