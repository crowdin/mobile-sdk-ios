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
}

extension CrowdinLogType {
    var color: UIColor {
        switch self {
        case .error:
            return .red
        case .info:
            return .black
        case .warning:
            return .yellow
        }
    }
}

struct CrowdinLog {
    let date = Date()
    let type: CrowdinLogType
    let message: String
    
    static func info(with message: String) -> CrowdinLog {
        return CrowdinLog(type: .info, message: message)
    }
    
    static func error(with message: String) -> CrowdinLog {
        return CrowdinLog(type: .error, message: message)
    }
    
    static func warning(with message: String) -> CrowdinLog {
        return CrowdinLog(type: .warning, message: message)
    }
}
