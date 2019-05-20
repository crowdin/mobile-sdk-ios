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
    
    var ws: WebSocket
    
    var error: ((Error) -> Void)? = nil
    var didChangeString: ((Int, String) -> Void)? = nil
    var didChangePlural: ((Int, String) -> Void)? = nil
    
    init(hashString: String, csrfToken: String, userAgent: String, cookies: [HTTPCookie]) {
        self.hashString = hashString
        self.csrfToken = csrfToken
        self.userAgent = userAgent
        self.cookies = cookies
        self.ws = WebSocket(url: URL(string: "wss://ws-lb.crowdin.com/")!)
        super.init()
        self.ws.delegate = self
        self.ws.connect()
        
        let api = DistributionsAPI(hashString: hashString, csrfToken: csrfToken, userAgent: userAgent, cookies: cookies)
        api.getDistribution { (response, _) in
            self.distributionResponse = response
        }
    }

    var distributionResponse: DistributionsResponse?
    
    func subscribeUpdateDraft(localization: String, stringId: Int) {
        guard let projectId = distributionResponse?.data.project.id else { return }
        guard let projectWsHash = distributionResponse?.data.project.wsHash else { return }
        guard let userId = distributionResponse?.data.user.id else { return }
        
        guard let data = "{\"action\":\"subscribe\",\"event\": \"update-draft:\(projectWsHash):\(projectId):\(userId):\(localization):\(stringId)\"}".data(using: .utf8) else { return }
        
        self.ws.write(data: data)
    }
    
    func subscribeTopSuggestion(localization: String, stringId: Int) {
        guard let projectId = distributionResponse?.data.project.id else { return }
        guard let projectWsHash = distributionResponse?.data.project.wsHash else { return }
        
        guard let data = "{\"action\":\"subscribe\",\"event\": \"top-suggestion:\(projectWsHash):\(projectId):\(localization):\(stringId)\"}".data(using: .utf8) else { return }
        
        self.ws.write(data: data)
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
//        guard let pluralForm = topSuggestion.data?. else { return }
//        if pluralForm == "none" {
//            self.didChangeString?(id, newText)
//        } else {
            self.didChangePlural?(id, newText)
//        }
    }
}

extension CrowdinSocketManager: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocketDidConnect")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocketDidDisconnect error - \(error)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("websocketDidReceiveMessage text - \(text)")
        guard let data = text.data(using: .utf8) else { return }
        if let response = try? JSONDecoder().decode(UpdateDraftResponse.self, from: data) {
            self.updateDraft(response)
        } else if let response = try? JSONDecoder().decode(TopSuggestionResponse.self, from: data) {
            self.updateTopSuggestion(response)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocketDidReceiveData")
    }
}
