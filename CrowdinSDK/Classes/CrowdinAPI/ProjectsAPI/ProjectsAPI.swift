//
//  ProjectsAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 09.02.2020.
//

import Foundation
import BaseAPI

class ProjectsAPI: CrowdinAPI {
    override var apiPath: String {
        return "projects"
    }
    
    func getFilesList(projectId: String, completion: @escaping (ProjectsFilesListResponse?, Error?) -> Void) {
        let url = "\(fullPath)/\(projectId)/files"
        self.cw_get(url: url, completion: completion)
    }
    
    func downloadFile(projectId: String, fileId: String, completion: @escaping (ProjectsDownloadFileResponse?, Error?) -> Void) {
        let url = "\(fullPath)/\(projectId)/files/\(fileId)/download"
        self.cw_get(url: url, completion: completion)
    }
    
    func downloadFileData(url: String, completion:  @escaping (Data?, Error?) -> Void) {
        self.get(url: url) { (data, _, error) in
            completion(data, error)
        }
    }
    func buildProjectFileTranslation(projectId: String, fileId: String, targetLanguageId: String, completion: @escaping (ProjectsDownloadFileResponse?, Error?) -> Void) {
        let headers = [RequestHeaderFields.contentType.rawValue: "application/json"]
        let body = try? JSONEncoder().encode(["targetLanguageId": targetLanguageId])
        let url = "\(fullPath)/\(projectId)/translations/builds/files/\(fileId)"
        self.cw_post(url: url, parameters: nil, headers: headers, body: body, completion: completion)
    }
}
