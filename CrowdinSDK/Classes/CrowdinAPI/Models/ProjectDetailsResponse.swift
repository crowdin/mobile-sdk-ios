//
//  ProjectDetailsResponse.swift
//  CrowdinAPI
//
//  Created by Serhii Londar on 3/21/19.
//

import Foundation

public class ProjectDetailsResponse: Codable {
    public let info: ProjectDetailsInfo?
    
    enum CodingKeys: String, CodingKey {
        case info = "info"
    }
    
    public init(info: ProjectDetailsInfo?) {
        self.info = info
    }
}

public class ProjectDetailsInfo: Codable {
    public let languages: ProjectDetailsLanguages?
    public let files: ProjectDetailsFiles?
    public let details: ProjectDetailsDetails?
    
    enum CodingKeys: String, CodingKey {
        case languages = "languages"
        case files = "files"
        case details = "details"
    }
}

public class ProjectDetailsDetails: Codable {
    public let sourceLanguage: ProjectDetailsSourceLanguage?
    public let name: String?
    public let identifier: String?
    public let created: String?
    public let joinPolicy: String?
    public let lastBuild: String?
    public let lastActivity: String?
    public let participantsCount: String?
    public let totalStringsCount: String?
    public let totalWordsCount: String?
    public let duplicateStringsCount: String?
    public let duplicateWordsCount: String?
    public let inviteurl: ProjectDetailsInviteurl?
    
    enum CodingKeys: String, CodingKey {
        case sourceLanguage = "source_language"
        case name = "name"
        case identifier = "identifier"
        case created = "created"
        case joinPolicy = "join_policy"
        case lastBuild = "last_build"
        case lastActivity = "last_activity"
        case participantsCount = "participants_count"
        case totalStringsCount = "total_strings_count"
        case totalWordsCount = "total_words_count"
        case duplicateStringsCount = "duplicate_strings_count"
        case duplicateWordsCount = "duplicate_words_count"
        case inviteurl = "invite_url"
    }
}

public class ProjectDetailsInviteurl: Codable {
    public let translator: String?
    public let proofreader: String?
    
    enum CodingKeys: String, CodingKey {
        case translator = "translator"
        case proofreader = "proofreader"
    }
}

public class ProjectDetailsSourceLanguage: Codable {
    public let name: String?
    public let code: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case code = "code"
    }
}

public class ProjectDetailsFiles: Codable {
    public let item: [ProjectDetailsFilesItem]?
    
    enum CodingKeys: String, CodingKey {
        case item = "item"
    }
}

public class ProjectDetailsFilesItem: Codable {
    public let nodeType: String?
    public let id: String?
    public let name: String?
    public let created: String?
    public let lastUpdated: String?
    public let lastRevision: String?
    public let lastAccessed: String?
    
    enum CodingKeys: String, CodingKey {
        case nodeType = "node_type"
        case id = "id"
        case name = "name"
        case created = "created"
        case lastUpdated = "last_updated"
        case lastRevision = "last_revision"
        case lastAccessed = "last_accessed"
    }
}

public class ProjectDetailsLanguages: Codable {
    public let item: [ProjectDetailsLanguagesItem]?
    
    enum CodingKeys: String, CodingKey {
        case item = "item"
    }
}

public class ProjectDetailsLanguagesItem: Codable {
    public let name: String?
    public let code: String?
    public let canTranslate: String?
    public let canApprove: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case code = "code"
        case canTranslate = "can_translate"
        case canApprove = "can_approve"
    }
}
