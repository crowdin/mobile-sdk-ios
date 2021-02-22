//
//  CrowidnLog.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 11.08.2020.
//

import Foundation

enum CrowdinLogType: String {
    
    case info
    case error
    case warning
    case rest
}

extension CrowdinLogType {
    
    var color: UIColor {
        switch self {
        case .error:
            return .red
        case .info:
            return .blue
        case .warning:
            return .yellow
        case .rest:
            return .orange
        }
    }
}

struct CrowdinLog {
    let date = Date()
    let type: CrowdinLogType
    let message: String
    var attributedDetails: NSAttributedString? = nil
    
    static func info(with message: String) -> CrowdinLog {
        CrowdinLog(type: .info, message: message)
    }
    
    static func error(with message: String) -> CrowdinLog {
        CrowdinLog(type: .error, message: message)
    }
    
    static func warning(with message: String) -> CrowdinLog {
        CrowdinLog(type: .warning, message: message)
    }
    
    static func rest(with message: String, attributedDetails: NSAttributedString? = nil) -> CrowdinLog {
        var log = CrowdinLog(type: .rest, message: message)
        log.attributedDetails = attributedDetails
        
        return log
    }
}
