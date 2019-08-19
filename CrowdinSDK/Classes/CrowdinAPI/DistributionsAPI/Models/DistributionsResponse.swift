//
//  DistributionsResponse.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/19/19.
//

import Foundation

// MARK: - DistributionsResponse
public struct DistributionsResponse: Codable {
    public let data: DistributionsResponseData
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
    public init(data: DistributionsResponseData) {
        self.data = data
    }
}

// MARK: - DistributionsResponseData
public struct DistributionsResponseData: Codable {
    public let project: DistributionsResponseProject
    public let user: DistributionsResponseUser
    
    enum CodingKeys: String, CodingKey {
        case project = "project"
        case user = "user"
    }
    
    public init(project: DistributionsResponseProject, user: DistributionsResponseUser) {
        self.project = project
        self.user = user
    }
}

// MARK: - DistributionsResponseProject
public struct DistributionsResponseProject: Codable {
    public let id: String
    public let wsHash: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case wsHash = "wsHash"
    }
    
    public init(id: String, wsHash: String) {
        self.id = id
        self.wsHash = wsHash
    }
}

// MARK: - DistributionsResponseUser
public struct DistributionsResponseUser: Codable {
    public let id: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
    }
    
    public init(id: String) {
        self.id = id
    }
}
