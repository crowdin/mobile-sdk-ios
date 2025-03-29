//
//  ScreenshotsListResponse.swift
//  Pods
//
//  Created by Serhii Londar on 10.11.2024.
//

import Foundation

// MARK: - ScreenshotsListResponse
struct ScreenshotsListResponse: Codable, Hashable {
    let data: [ScreenshotsListResponseDatum]
    let pagination: ScreenshotsListResponsePagination

    enum CodingKeys: String, CodingKey {
        case data
        case pagination
    }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - ScreenshotsListResponseDatum
struct ScreenshotsListResponseDatum: Codable, Hashable {
    let data: ScreenshotsListResponseData

    enum CodingKeys: String, CodingKey {
        case data
    }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - ScreenshotsListResponseData
struct ScreenshotsListResponseData: Codable, Hashable {
    let id: Int
    let userID: Int
    let url: String
    let webURL: String
    let name: String
    let size: ScreenshotsListResponseSize
    let tagsCount: Int
    let tags: [ScreenshotsListResponseTag]
    let labels: [Int]
    let labelIDS: [Int]
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userID = "userId"
        case url = "url"
        case webURL = "webUrl"
        case name = "name"
        case size = "size"
        case tagsCount = "tagsCount"
        case tags = "tags"
        case labels = "labels"
        case labelIDS = "labelIds"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - ScreenshotsListResponseSize
struct ScreenshotsListResponseSize: Codable, Hashable {
    let width: Int
    let height: Int

    enum CodingKeys: String, CodingKey {
        case width
        case height
    }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - ScreenshotsListResponseTag
struct ScreenshotsListResponseTag: Codable, Hashable {
    let id: Int
    let screenshotID: Int
    let stringID: Int
    let position: ScreenshotsListResponsePosition
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case screenshotID
        case stringID
        case position
        case createdAt
    }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - ScreenshotsListResponsePosition
struct ScreenshotsListResponsePosition: Codable, Hashable {
    let x: Int
    let y: Int
    let width: Int
    let height: Int

    enum CodingKeys: String, CodingKey {
        case x
        case y
        case width
        case height
    }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - ScreenshotsListResponsePagination
struct ScreenshotsListResponsePagination: Codable, Hashable {
    let offset: Int
    let limit: Int

    enum CodingKeys: String, CodingKey {
        case offset
        case limit
    }
}
