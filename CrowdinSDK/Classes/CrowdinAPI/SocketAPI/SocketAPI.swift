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
    let distributionsAPI: DistributionsAPI
    
    var distributionResponse: DistributionsResponse?
    var ws: WebSocket
    var onConnect: (() -> Void)? = nil
    var onError: ((Error) -> Void)? = nil
    var didReceiveUpdateDraft: ((UpdateDraftResponse) -> Void)? = nil
    var didReceiveUpdateTopSuggestion: ((TopSuggestionResponse) -> Void)? = nil
    
    var isConnected: Bool {
        return ws.isConnected
    }
    
    init(hashString: String) {
        self.hashString = hashString
        self.distributionsAPI = DistributionsAPI(hashString: hashString)
        // swiftlint:disable force_unwrapping
        self.ws = WebSocket(url: URL(string: urlString)!)
        super.init()
        self.ws.delegate = self
        self.getDistribution()
    }
    
    func getDistribution(completion: (() -> Void)? = nil) {
        distributionsAPI.getDistribution { (response, error) in
            self.distributionResponse = response
            if let error = error {
                self.disconect()
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
        
        let event = "\(Events.updateDraft.rawValue):\(projectWsHash):\(projectId):\(userId):\(localization):\(stringId)"
        let action = ActionRequest.subscribeAction(with: event)
        guard let data = action.data else { return }
        
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
