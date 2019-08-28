//
//  SocketAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/21/19.
//

import Foundation
import Starscream

class SocketAPI: NSObject {
    let urlString = "wss://ws-lb.crowdin.com/"
    let hashString: String
	let projectId: String
	let projectWsHash: String
	let userId: String
	
    var ws: WebSocket
    var onConnect: (() -> Void)? = nil
    var onError: ((Error) -> Void)? = nil
    var didReceiveUpdateDraft: ((UpdateDraftResponse) -> Void)? = nil
    var didReceiveUpdateTopSuggestion: ((TopSuggestionResponse) -> Void)? = nil
    
    var isConnected: Bool {
        return ws.isConnected
    }
    
	init(hashString: String, projectId: String, projectWsHash: String, userId: String) {
        self.hashString = hashString
		self.projectId = projectId
		self.projectWsHash = projectWsHash
		self.userId = userId
        // swiftlint:disable force_unwrapping
        self.ws = WebSocket(url: URL(string: urlString)!)
        super.init()
        self.ws.delegate = self
    }
    
    func connect() {
        self.ws.connect()
    }
    
    func disconect() {
        self.ws.disconnect()
    }
    
    func subscribeOnUpdateDraft(localization: String, stringId: Int) {
        let event = "\(Events.updateDraft.rawValue):\(projectWsHash):\(projectId):\(userId):\(localization):\(stringId)"
        let action = ActionRequest.subscribeAction(with: event)
        guard let data = action.data else { return }
        
        self.ws.write(data: data)
    }
    
    func subscribeOnUpdateTopSuggestion(localization: String, stringId: Int) {
        let event = "\(Events.topSuggestion.rawValue):\(projectWsHash):\(projectId):\(localization):\(stringId)"
        let action = ActionRequest.subscribeAction(with: event)
        guard let data = action.data else { return }
        
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
            self.onError?(NSError(domain: Errors.didDisconect.rawValue, code: defaultCrowdinErrorCode, userInfo: nil))
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

extension SocketAPI {
    enum Events: String {
        case topSuggestion = "top-suggestion"
        case updateDraft = "update-draft"
    }
    
    enum Errors: String {
        case didDisconect = "Websocket did disconnect with unknown error"
    }
}
