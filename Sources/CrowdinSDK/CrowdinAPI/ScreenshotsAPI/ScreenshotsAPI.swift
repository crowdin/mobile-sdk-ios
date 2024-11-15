//
//  ScreenshotsAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/9/19.
//

import Foundation
import CoreGraphics
import BaseAPI

class ScreenshotsAPI: CrowdinAPI {
    override var apiPath: String {
        return "projects"
    }
    
    func baseUrl(with projectId: Int) -> String{
        return "\(fullPath)/\(projectId)/screenshots"
    }

    func createScreenshot(projectId: Int, storageId: Int, name: String, autoTag: Bool = false, completion: @escaping (CreateScreenshotResponse?, Error?) -> Void) {
        let request = CreateScreenshotRequest(storageId: storageId, name: name, autoTag: autoTag)
        let requestData = try? JSONEncoder().encode(request)
        let url = baseUrl(with: projectId)
        let headers = [RequestHeaderFields.contentType.rawValue: "application/json"]
        self.cw_post(url: url, headers: headers, body: requestData, completion: completion)
    }
    
    func updateScreenshot(projectId: Int, screnshotId: Int, storageId: Int, name: String, usePreviousTags: Bool = false, completion: @escaping (CreateScreenshotResponse?, Error?) -> Void) {
        let request = UpdateScreenshotRequest(storageId: storageId, name: name, usePreviousTags: usePreviousTags)
        let requestData = try? JSONEncoder().encode(request)
        let url = baseUrl(with: projectId) + "/" + String(screnshotId)
        let headers = [RequestHeaderFields.contentType.rawValue: "application/json"]
        self.cw_put(url: url, headers: headers, body: requestData, completion: completion)
    }
    
    func createScreenshotTags(projectId: Int, screenshotId: Int, frames: [(id: Int, rect: CGRect)], completion: @escaping (CreateScreenshotTagResponse?, Error?) -> Void) {
        var elements = [CreateScreenshotTagRequestElement]()
        for frame in frames {
            let key = frame.id
            let value = frame.rect
            elements.append(CreateScreenshotTagRequestElement(stringId: key, position: CreateScreenshotTagPosition(x: Int(value.origin.x), y: Int(value.origin.y), width: Int(value.size.width), height: Int(value.size.height))))
        }
        let request = elements
        let requestData = try? JSONEncoder().encode(request)
        let url = baseUrl(with: projectId) + "/\(screenshotId)/tags"
        let headers = [RequestHeaderFields.contentType.rawValue: "application/json"]
        self.cw_post(url: url, headers: headers, body: requestData, completion: completion)
    }
    
    enum ListScreenshotsParameters: String {
        case search
        case orderBy
        case limit
        case offset
    }
    
    func listScreenshots(projectId: Int, query: String, completion: @escaping (ScreenshotsListResponse?, Error?) -> Void) {
        let parameters = [
            ListScreenshotsParameters.search.rawValue: query,
            ListScreenshotsParameters.orderBy.rawValue: "createdAt desc,updatedAt desc",
            ListScreenshotsParameters.offset.rawValue: "0",
            ListScreenshotsParameters.limit.rawValue: "2"
        ]
        let url = baseUrl(with: projectId)
        self.cw_get(url: url, parameters: parameters, completion: completion)
    }
}

extension String {
    func urlEncoded() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
    }
}
