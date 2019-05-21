//
//  SocketConnectionManager.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/6/19.
//

import Foundation
import Starscream

class CrowdinSocketManager: NSObject {
    let hashString: String
    let csrfToken: String
    let userAgent: String
    let cookies: [HTTPCookie]
    
    var socketAPI: SocketAPI
    var active: Bool {
        return socketAPI.isConnected
    }
    
    var error: ((Error) -> Void)? = nil
    var didChangeString: ((Int, String) -> Void)? = nil
    var didChangePlural: ((Int, String) -> Void)? = nil
    
    init(hashString: String, csrfToken: String, userAgent: String, cookies: [HTTPCookie]) {
        self.hashString = hashString
        self.csrfToken = csrfToken
        self.userAgent = userAgent
        self.cookies = cookies
        self.socketAPI = SocketAPI(hashString: hashString, csrfToken: csrfToken, userAgent: userAgent, cookies: cookies)
        super.init()
        
        self.socketAPI.didReceiveUpdateTopSuggestion = updateTopSuggestion(_:)
        self.socketAPI.didReceiveUpdateDraft = updateDraft(_:)
    }
    
    func start() {
        self.socketAPI.connect()
    }
    
    func stop() {
        self.socketAPI.disconect()
    }
    
    var distributionResponse: DistributionsResponse?
    
    func subscribeOnUpdateDraft(localization: String, stringId: Int) {
        self.socketAPI.subscribeOnUpdateDraft(localization: localization, stringId: stringId)
    }
    
    func subscribeOnUpdateTopSuggestion(localization: String, stringId: Int) {
        self.socketAPI.subscribeOnUpdateTopSuggestion(localization: localization, stringId: stringId)
    }
    
    func updateDraft(_ draft: UpdateDraftResponse) {
        guard let event = draft.event else { return }
        let data = event.split(separator: ":").map({ String($0) })
        guard data.count == 6 else { return }
        guard let id = Int(data[5]) else { return }
        guard let newText = draft.data?.text else { return }
        guard let pluralForm = draft.data?.pluralForm else { return }
        if pluralForm == "none" {
            self.didChangeString?(id, newText)
        } else {
            self.didChangePlural?(id, newText)
        }
    }
    
    func updateTopSuggestion(_ topSuggestion: TopSuggestionResponse) {
        guard let event = topSuggestion.event else { return }
        let data = event.split(separator: ":").map({ String($0) })
        guard data.count == 5 else { return }
        guard let id = Int(data[4]) else { return }
        guard let newText = topSuggestion.data?.text else { return }
        
        // TODO: Fix in future.
        // We're unable to detect what exact was changed string or plural. Send two callbacks.
        self.didChangeString?(id, newText)
        self.didChangePlural?(id, newText)
    }
}
