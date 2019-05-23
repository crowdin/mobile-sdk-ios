//
//  DistributionsResponse.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/19/19.
//

import Foundation

struct DistributionsResponse: Codable {
    let success: Bool
    let data: DistributionsData
    let version: String
}

struct DistributionsData: Codable {
    let project: DistributionsProject
    let user: DistributionsUser
}

struct DistributionsProject: Codable {
    let id, wsHash: String
}

struct DistributionsUser: Codable {
    let id: String
}

