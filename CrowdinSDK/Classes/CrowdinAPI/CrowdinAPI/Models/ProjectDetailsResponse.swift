//
//  ProjectDetailsResponse.swift
//  CrowdinAPI
//
//  Created by Serhii Londar on 3/21/19.
//

import Foundation

public class ProjectDetailsResponse: Codable {
    public let languages: [ProjectDetailsResponseLanguage]?
    public let files: [ProjectDetailsResponseFile]?
    public let details: ProjectDetailsResponseDetails?
    
    enum CodingKeys: String, CodingKey {
        case languages = "languages"
        case files = "files"
        case details = "details"
    }
    
    public init(languages: [ProjectDetailsResponseLanguage]?, files: [ProjectDetailsResponseFile]?, details: ProjectDetailsResponseDetails?) {
        self.languages = languages
        self.files = files
        self.details = details
    }
}

public class ProjectDetailsResponseDetails: Codable {
    public let sourceLanguage: ProjectDetailsResponseSourceLanguage?
    public let name: String?
    public let identifier: String?
    public let created: String?
    public let description: String?
    public let joinPolicy: String?
    public let lastBuild: String?
    public let lastActivity: String?
    public let participantsCount: String?
    public let logourl: String?
    public let totalStringsCount: String?
    public let totalWordsCount: String?
    public let duplicateStringsCount: Int?
    public let duplicateWordsCount: Int?
    public let inviteurl: ProjectDetailsResponseInviteurl?
    
    enum CodingKeys: String, CodingKey {
        case sourceLanguage = "source_language"
        case name = "name"
        case identifier = "identifier"
        case created = "created"
        case description = "description"
        case joinPolicy = "join_policy"
        case lastBuild = "last_build"
        case lastActivity = "last_activity"
        case participantsCount = "participants_count"
        case logourl = "logo_url"
        case totalStringsCount = "total_strings_count"
        case totalWordsCount = "total_words_count"
        case duplicateStringsCount = "duplicate_strings_count"
        case duplicateWordsCount = "duplicate_words_count"
        case inviteurl = "invite_url"
    }
    
    public init(sourceLanguage: ProjectDetailsResponseSourceLanguage?, name: String?, identifier: String?, created: String?, description: String?, joinPolicy: String?, lastBuild: String?, lastActivity: String?, participantsCount: String?, logourl: String?, totalStringsCount: String?, totalWordsCount: String?, duplicateStringsCount: Int?, duplicateWordsCount: Int?, inviteurl: ProjectDetailsResponseInviteurl?) {
        self.sourceLanguage = sourceLanguage
        self.name = name
        self.identifier = identifier
        self.created = created
        self.description = description
        self.joinPolicy = joinPolicy
        self.lastBuild = lastBuild
        self.lastActivity = lastActivity
        self.participantsCount = participantsCount
        self.logourl = logourl
        self.totalStringsCount = totalStringsCount
        self.totalWordsCount = totalWordsCount
        self.duplicateStringsCount = duplicateStringsCount
        self.duplicateWordsCount = duplicateWordsCount
        self.inviteurl = inviteurl
    }
}

public class ProjectDetailsResponseInviteurl: Codable {
    public let translator: String?
    public let proofreader: String?
    
    enum CodingKeys: String, CodingKey {
        case translator = "translator"
        case proofreader = "proofreader"
    }
    
    public init(translator: String?, proofreader: String?) {
        self.translator = translator
        self.proofreader = proofreader
    }
}

public class ProjectDetailsResponseSourceLanguage: Codable {
    public let name: String?
    public let code: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case code = "code"
    }
    
    public init(name: String?, code: String?) {
        self.name = name
        self.code = code
    }
}

public class ProjectDetailsResponseFile: Codable {
    public let nodeType: String?
    public let id: String?
    public let name: String?
    public let created: String?
    public let lastUpdated: String?
    public let lastAccessed: String?
    public let lastRevision: String?
    
    enum CodingKeys: String, CodingKey {
        case nodeType = "node_type"
        case id = "id"
        case name = "name"
        case created = "created"
        case lastUpdated = "last_updated"
        case lastAccessed = "last_accessed"
        case lastRevision = "last_revision"
    }
    
    public init(nodeType: String?, id: String?, name: String?, created: String?, lastUpdated: String?, lastAccessed: String?, lastRevision: String?) {
        self.nodeType = nodeType
        self.id = id
        self.name = name
        self.created = created
        self.lastUpdated = lastUpdated
        self.lastAccessed = lastAccessed
        self.lastRevision = lastRevision
    }
}

public class ProjectDetailsResponseLanguage: Codable {
    public let name: String?
    public let code: String?
    public let canTranslate: Int?
    public let canApprove: Int?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case code = "code"
        case canTranslate = "can_translate"
        case canApprove = "can_approve"
    }
    
    public init(name: String?, code: String?, canTranslate: Int?, canApprove: Int?) {
        self.name = name
        self.code = code
        self.canTranslate = canTranslate
        self.canApprove = canApprove
    }
}
