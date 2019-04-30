//
//  RealtimeUpdateFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/5/19.
//

import Foundation
import SocketIO

class RealtimeUpdateFeature {
    static var shared: RealtimeUpdateFeature?
    
    private var controls = NSHashTable<AnyObject>.weakObjects()
    
    func subscribe(control: Refreshable) {
        controls.add(control)
    }
    
    func refresh() {
        self.controls.allObjects.forEach { (control) in
            if let refreshable = control as? Refreshable {
                refreshable.refresh()
            }
        }
    }
    
    func login() {
        guard let loginVC = CrowdinLoginVC.instantiateVC else { return }
        loginVC.csrfTokenCompletion = { token in
            self.start(with: token)
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(loginVC, animated: true, completion: { })
    }
    var manager: SocketManager!
    var socket: SocketIOClient!
    
    func start(with token: String) {
        manager = SocketManager(socketURL: URL(string: "https://crowdin.com/backend/distributions/get_info?distribution_hash=66f02b964afeb77aea8d191e68748abc&X-Csrf-Token=\(token)")!, config: [.log(true), .compress])
        socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) {_, _ in
            print("socket connected")
        }
        
        socket.onAny { (event) in
            print(event.description)
        }
        
        socket.connect()
    }
}
