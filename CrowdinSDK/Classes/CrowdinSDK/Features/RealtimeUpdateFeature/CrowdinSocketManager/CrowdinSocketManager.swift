//
//  SocketConnectionManager.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/6/19.
//

import Foundation
import SocketRocket

class CrowdinSocketManager: NSObject {
    let csrf_token: String
    
    var open: (() -> Void)? = nil
    var error: ((Error) -> Void)? = nil
    var close: (() -> Void)? = nil
    var didChangeString: ((Int, String) -> Void)? = nil
    var didChangePlural: ((Int, String) -> Void)? = nil
    
    init(csrf_token: String) {
        self.csrf_token = csrf_token
        super.init()
        self.start()
    }
    
    func start() {
        var request = URLRequest(url: URL(string:"https://crowdin.com/backend/distributions/get_info?distribution_hash=66f02b964afeb77aea8d191e68748abc")!)
        request.addValue(csrf_token, forHTTPHeaderField: "csrf_token") // X-Csrf-Token
        let ws = SRWebSocket(urlRequest: request)
        ws?.delegate = self
        ws?.open()
    }
}

extension CrowdinSocketManager: SRWebSocketDelegate {
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        print(message)
    }
    
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        print("OPEN")
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        print(error)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceivePong pongPayload: Data!) {
        print("didReceivePong")
    }
    
    func webSocketShouldConvertTextFrame(toString webSocket: SRWebSocket!) -> Bool {
        return true
    }
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        print("CLOSE")
    }
}
