//
//  LogsCollector.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 11.08.2020.
//

import Foundation

class CrowdinLogsCollector {
    static let shared = CrowdinLogsCollector()
    
    fileprivate var _logs = Atomic<[CrowdinLog]>([])
    
    var logs: [CrowdinLog] {
        return _logs.value
    }
    
    func add(log: CrowdinLog) {
        _logs.mutate { $0.append(log) }
        
//        guard CrowdinSDK.config.debugEnabled else {
//            return
//        }
        
        print("CrowdinSDK: \(log.message)")
    }
    
    func clear() {
        _logs.mutate { $0.removeAll() }
    }
}
