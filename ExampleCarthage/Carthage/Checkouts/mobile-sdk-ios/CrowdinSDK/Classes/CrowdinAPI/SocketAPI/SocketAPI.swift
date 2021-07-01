//
//  SocketAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/21/19.
//

import Foundation
import Starscream

class SocketAPI: NSObject {
    fileprivate let defaultCrowdinErrorCode = 9999
    let hashString: String
	let projectId: String
	let projectWsHash: String
	let userId: String
	var wsUrl: String
	
    var ws: WebSocket
    var onConnect: (() -> Void)? = nil
    var onError: ((Error) -> Void)? = nil
    var onDisconnect: (() -> Void)? = nil
    var didReceiveUpdateDraft: ((UpdateDraftResponse) -> Void)? = nil
    var didReceiveUpdateTopSuggestion: ((TopSuggestionResponse) -> Void)? = nil
    
    var isConnected: Bool {
        return ws.isConnected
    }
    
	init(hashString: String, projectId: String, projectWsHash: String, userId: String, wsUrl: String) {
        self.hashString = hashString
		self.projectId = projectId
		self.projectWsHash = projectWsHash
		self.userId = userId
		self.wsUrl = wsUrl
		
        // swiftlint:disable force_unwrapping
        self.ws = WebSocket(url: URL(string: wsUrl)!)
        super.init()
        self.ws.delegate = self
    }
    
    func connect() {
        self.ws.connect()
    }
    
    func disconect() {
        self.ws.disconnect(forceTimeout: 1, closeCode: CloseCode.normal.rawValue)
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
        onConnect?()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let wsError = error as? WSError, wsError.code == CloseCode.normal.rawValue {
            self.onDisconnect?()
        } else if let error = error {
            self.onError?(error)
        } else {
            self.onDisconnect?()
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
