//
//  SupportedLanguagesResponse.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/26/19.
//

import Foundation

// MARK: - LanguagesResponse
public struct LanguagesResponse: Codable {
    public let data: [LanguagesResponseDatum]
    public let pagination: LanguagesResponsePagination

    enum CodingKeys: String, CodingKey {
        case data = "data"
        case pagination = "pagination"
    }

    public init(data: [LanguagesResponseDatum], pagination: LanguagesResponsePagination) {
        self.data = data
        self.pagination = pagination
    }
}

// MARK: - LanguagesResponseDatum
public struct LanguagesResponseDatum: Codable {
    public let data: LanguagesResponseData

    enum CodingKeys: String, CodingKey {
        case data = "data"
    }

    public init(data: LanguagesResponseData) {
        self.data = data
    }
}

// MARK: - LanguagesResponseData
public struct LanguagesResponseData: Codable {
    public let id: String
    public let name: String
    public let editorCode: String
    public let twoLettersCode: String
    public let threeLettersCode: String
    public let locale: String
    public let androidCode: String
    public let osxCode: String
    public let osxLocale: String
    public let pluralCategoryNames: [LanguagesResponsePluralCategoryName]
    public let pluralRules: String
    public let pluralExamples: [String]
    public let textDirection: LanguagesResponseTextDirection
    public let dialectOf: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case editorCode = "editorCode"
        case twoLettersCode = "twoLettersCode"
        case threeLettersCode = "threeLettersCode"
        case locale = "locale"
        case androidCode = "androidCode"
        case osxCode = "osxCode"
        case osxLocale = "osxLocale"
        case pluralCategoryNames = "pluralCategoryNames"
        case pluralRules = "pluralRules"
        case pluralExamples = "pluralExamples"
        case textDirection = "textDirection"
        case dialectOf = "dialectOf"
    }

    public init(id: String, name: String, editorCode: String, twoLettersCode: String, threeLettersCode: String, locale: String, androidCode: String, osxCode: String, osxLocale: String, pluralCategoryNames: [LanguagesResponsePluralCategoryName], pluralRules: String, pluralExamples: [String], textDirection: LanguagesResponseTextDirection, dialectOf: String?) {
        self.id = id
        self.name = name
        self.editorCode = editorCode
        self.twoLettersCode = twoLettersCode
        self.threeLettersCode = threeLettersCode
        self.locale = locale
        self.androidCode = androidCode
        self.osxCode = osxCode
        self.osxLocale = osxLocale
        self.pluralCategoryNames = pluralCategoryNames
        self.pluralRules = pluralRules
        self.pluralExamples = pluralExamples
        self.textDirection = textDirection
        self.dialectOf = dialectOf
    }
}

public enum LanguagesResponsePluralCategoryName: String, Codable {
    case few = "few"
    case many = "many"
    case one = "one"
    case other = "other"
    case two = "two"
    case zero = "zero"
}

public enum LanguagesResponseTextDirection: String, Codable {
    case ltr = "ltr"
    case rtl = "rtl"
}

// MARK: - LanguagesResponsePagination
public struct LanguagesResponsePagination: Codable {
    public let offset: Int
    public let limit: Int

    enum CodingKeys: String, CodingKey {
        case offset = "offset"
        case limit = "limit"
    }

    public init(offset: Int, limit: Int) {
        self.offset = offset
        self.limit = limit
    }
}
