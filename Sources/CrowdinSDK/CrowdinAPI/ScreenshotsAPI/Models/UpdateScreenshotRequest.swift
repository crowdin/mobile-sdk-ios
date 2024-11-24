//
//  UpdateScreenshotRequest.swift
//  Pods
//
//  Created by Serhii Londar on 09.11.2024.
//

struct UpdateScreenshotRequest: Codable {
    let storageId: Int
    let name: String
    var usePreviousTags: Bool = true
}
