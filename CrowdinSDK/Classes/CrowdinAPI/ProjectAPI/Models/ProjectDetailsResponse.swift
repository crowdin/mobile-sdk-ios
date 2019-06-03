//
//  ProjectDetailsResponse.swift
//  CrowdinAPI
//
//  Created by Serhii Londar on 3/21/19.
//

import Foundation

class ProjectDetailsResponse: Codable {
    let languages: [ProjectDetailsResponseLanguage]?
    let files: [ProjectDetailsResponseFile]?
    let details: ProjectDetailsResponseDetails?
    
    enum CodingKeys: String, CodingKey {
        case languages
        case files
        case details
    }
    
    init(languages: [ProjectDetailsResponseLanguage]?, files: [ProjectDetailsResponseFile]?, details: ProjectDetailsResponseDetails?) {
        self.languages = languages
        self.files = files
        self.details = details
    }
}

class ProjectDetailsResponseDetails: Codable {
    let sourceLanguage: ProjectDetailsResponseSourceLanguage?
    let name: String?
    let identifier: String?
    let created: String?
    let description: String?
    let joinPolicy: String?
    let lastBuild: String?
    let lastActivity: String?
    let participantsCount: String?
    let logourl: String?
    let totalStringsCount: String?
    let totalWordsCount: String?
    let duplicateStringsCount: Int?
    let duplicateWordsCount: Int?
    let inviteurl: ProjectDetailsResponseInviteurl?
    
    enum CodingKeys: String, CodingKey {
        case sourceLanguage = "source_language"
        case name
        case identifier
        case created
        case description
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
    
    init(sourceLanguage: ProjectDetailsResponseSourceLanguage?, name: String?, identifier: String?, created: String?, description: String?, joinPolicy: String?, lastBuild: String?, lastActivity: String?, participantsCount: String?, logourl: String?, totalStringsCount: String?, totalWordsCount: String?, duplicateStringsCount: Int?, duplicateWordsCount: Int?, inviteurl: ProjectDetailsResponseInviteurl?) {
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

class ProjectDetailsResponseInviteurl: Codable {
    let translator: String?
    let proofreader: String?
    
    enum CodingKeys: String, CodingKey {
        case translator
        case proofreader
    }
    
    init(translator: String?, proofreader: String?) {
        self.translator = translator
        self.proofreader = proofreader
    }
}

class ProjectDetailsResponseSourceLanguage: Codable {
    let name: String?
    let code: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case code
    }
    
    init(name: String?, code: String?) {
        self.name = name
        self.code = code
    }
}

class ProjectDetailsResponseFile: Codable {
    let nodeType: String?
    let id: String?
    let name: String?
    let created: String?
    let lastUpdated: String?
    let lastAccessed: String?
    let lastRevision: String?
    
    enum CodingKeys: String, CodingKey {
        case nodeType = "node_type"
        case id
        case name
        case created
        case lastUpdated = "last_updated"
        case lastAccessed = "last_accessed"
        case lastRevision = "last_revision"
    }
    
    init(nodeType: String?, id: String?, name: String?, created: String?, lastUpdated: String?, lastAccessed: String?, lastRevision: String?) {
        self.nodeType = nodeType
        self.id = id
        self.name = name
        self.created = created
        self.lastUpdated = lastUpdated
        self.lastAccessed = lastAccessed
        self.lastRevision = lastRevision
    }
}

class ProjectDetailsResponseLanguage: Codable {
    let name: String?
    let code: String?
    let canTranslate: Int?
    let canApprove: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case code
        case canTranslate = "can_translate"
        case canApprove = "can_approve"
    }
    
    init(name: String?, code: String?, canTranslate: Int?, canApprove: Int?) {
        self.name = name
        self.code = code
        self.canTranslate = canTranslate
        self.canApprove = canApprove
    }
}
