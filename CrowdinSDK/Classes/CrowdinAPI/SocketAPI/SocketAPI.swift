//
//  SocketAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/21/19.
//

import Foundation
import Starscream

class SocketAPI: NSObject {
    let hashString: String
    let csrfToken: String
    let userAgent: String
    let cookies: [HTTPCookie]
    
    var distributionResponse: DistributionsResponse?
    var ws: WebSocket
    var isConnected: Bool {
        return ws.isConnected
    }
    
    var onConnect: (() -> Void)? = nil
    var onError: ((Error) -> Void)? = nil
    var didReceiveUpdateDraft: ((UpdateDraftResponse) -> Void)? = nil
    var didReceiveUpdateTopSuggestion: ((TopSuggestionResponse) -> Void)? = nil
    
    init(hashString: String, csrfToken: String, userAgent: String, cookies: [HTTPCookie]) {
        self.hashString = hashString
        self.csrfToken = csrfToken
        self.userAgent = userAgent
        self.cookies = cookies
        // swiftlint:disable force_unwrapping
        self.ws = WebSocket(url: URL(string: "wss://ws-lb.crowdin.com/")!)
        super.init()
        self.ws.delegate = self
        
        self.getDistribution()
    }
    
    func getDistribution(completion: (() -> Void)? = nil) {
        let api = DistributionsAPI(hashString: hashString, csrfToken: csrfToken, userAgent: userAgent, cookies: cookies)
        api.getDistribution { (response, error) in
            self.distributionResponse = response
            if let error = error {
                self.onError?(error)
            } else {
                completion?()
            }
        }
    }
    
    func connect() {
        self.ws.connect()
    }
    
    func disconect() {
        self.ws.disconnect()
    }
    
    func subscribeOnUpdateDraft(localization: String, stringId: Int) {
        guard let distributionResponse = self.distributionResponse else {
            self.getDistribution(completion: {
                self.subscribeOnUpdateDraft(localization: localization, stringId: stringId)
            })
            return
        }
        let projectId = distributionResponse.data.project.id
        let projectWsHash = distributionResponse.data.project.wsHash
        let userId = distributionResponse.data.user.id
        
        // TODO: Rewrite to codable models:
        guard let data = "{\"action\":\"subscribe\",\"event\": \"update-draft:\(projectWsHash):\(projectId):\(userId):\(localization):\(stringId)\"}".data(using: .utf8) else { return }
        
        self.ws.write(data: data)
    }
    
    func subscribeOnUpdateTopSuggestion(localization: String, stringId: Int) {
        guard let distributionResponse = self.distributionResponse else {
            self.getDistribution(completion: {
                self.subscribeOnUpdateTopSuggestion(localization: localization, stringId: stringId)
            })
            return
        }
        let projectId = distributionResponse.data.project.id
        let projectWsHash = distributionResponse.data.project.wsHash
        
        // TODO: Rewrite to codable models:
        guard let data = "{\"action\":\"subscribe\",\"event\": \"top-suggestion:\(projectWsHash):\(projectId):\(localization):\(stringId)\"}".data(using: .utf8) else { return }
        
        self.ws.write(data: data)
    }
}

extension SocketAPI: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        self.onConnect?()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let error = error {
            self.onError?(error)
        } else {
            self.onError?(NSError(domain: "Websocket did disconnect with unknown error", code: 9999, userInfo: nil))
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let data = text.data(using: .utf8) else { return }
        if let response = try? JSONDecoder().decode(UpdateDraftResponse.self, from: data) {
            self.didReceiveUpdateDraft?(response)
        } else if let response = try? JSONDecoder().decode(TopSuggestionResponse.self, from: data) {
            self.didReceiveUpdateTopSuggestion?(response)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) { }
}
