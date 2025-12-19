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
    
    private let websocketAPI: WebsocketAPI
    private let organizationName: String?
    private let auth: CrowdinAuth?

    var ws: WebSocket
    var onConnect: (() -> Void)? = nil
    var onError: ((Error) -> Void)? = nil
    var onDisconnect: (() -> Void)? = nil
    var didReceiveUpdateDraft: ((UpdateDraftResponse) -> Void)? = nil
    var didReceiveUpdateTopSuggestion: ((TopSuggestionResponse) -> Void)? = nil

    var isConnected = false

	init(hashString: String, projectId: String, projectWsHash: String, userId: String, wsUrl: String, organizationName: String? = nil, auth: CrowdinAuth? = nil) {
        self.hashString = hashString
		self.projectId = projectId
		self.projectWsHash = projectWsHash
		self.userId = userId
		self.wsUrl = wsUrl
        self.organizationName = organizationName
        self.auth = auth
        self.websocketAPI = WebsocketAPI(organizationName: organizationName, auth: auth)

        // swiftlint:disable force_unwrapping
        var request = URLRequest(url: URL(string: wsUrl)!)
        request.allHTTPHeaderFields = CrowdinAPI.versioned(nil)
        ws = WebSocket(request: request)
        super.init()
        ws.delegate = self
    }

    func connect() {
        ws.connect()
    }

    func disconect() {
        ws.disconnect()
    }

    func reconnect() {
        disconect()
        connect()
    }

    func subscribeOnUpdateDraft(localization: String, stringId: Int) {
        let event = "\(Events.updateDraft.rawValue):\(projectWsHash):\(projectId):\(userId):\(localization):\(stringId)"
        
        // Get ticket for the event asynchronously
        websocketAPI.getWebsocketTicket(event: event) { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.onError?(error)
                return
            }
            
            if let ticket = response?.data.ticket {
                let action = ActionRequest.subscribeAction(with: event, ticket: ticket)
                guard let data = action.data else { return }
                
                self.ws.write(data: data)
            }
        }
    }

    func subscribeOnUpdateTopSuggestion(localization: String, stringId: Int) {
        let event = "\(Events.topSuggestion.rawValue):\(projectWsHash):\(projectId):\(localization):\(stringId)"
        
        // Get ticket for the event asynchronously
        websocketAPI.getWebsocketTicket(event: event) { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.onError?(error)
                return
            }
            
            if let ticket = response?.data.ticket {
                let action = ActionRequest.subscribeAction(with: event, ticket: ticket)
                guard let data = action.data else { return }
                
                self.ws.write(data: data)
            }
        }
    }

    func websocketDidReceiveText(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        if let response = try? JSONDecoder().decode(UpdateDraftResponse.self, from: data) {
            self.didReceiveUpdateDraft?(response)
        } else if let response = try? JSONDecoder().decode(TopSuggestionResponse.self, from: data) {
            self.didReceiveUpdateTopSuggestion?(response)
        }
    }
}

extension SocketAPI: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected:
            isConnected = true
            onConnect?()
        case .disconnected:
            isConnected = false
            onDisconnect?()
        case .text(let string):
            websocketDidReceiveText(string)
        case .binary: break
        case .ping: break
        case .pong: break
        case .viabilityChanged: break
            // the viability (connection status) of the connection has updated.
            // e.g. connection is down, connection came back up https://github.com/daltoniam/Starscream/issues/798
        case .reconnectSuggested(let shouldReconnect):
            // the connection has upgrade to wifi from cellular. Consider reconnecting to take advantage of this
            if shouldReconnect {
                reconnect()
            }
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            onError?(error ?? Errors.didDisconect)
        case .peerClosed:
            isConnected = false
        }
    }
}

extension SocketAPI {
    enum Events: String {
        case topSuggestion = "top-suggestion"
        case updateDraft = "update-draft"
    }

    enum Errors: Error, LocalizedError {
        case didDisconect

        var errorDescription: String? {
            switch self {
            case .didDisconect:
                return NSLocalizedString("Websocket did disconnect with unknown error", comment: "didDisconect")
            }
        }
    }
}
