//
//  ActionRequest.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 6/2/19.
//

import Foundation

struct ActionRequest: Codable {
    let action: String
    let event: String
    let ticket: String
    
    enum Events: String {
        case subscribe
    }
    
    static func subscribeAction(with event: String, ticket: String) -> ActionRequest {
        return ActionRequest(action: Events.subscribe.rawValue, event: event, ticket: ticket)
    }

    var data: Data? {
        return try? JSONEncoder().encode(self)
    }
}
