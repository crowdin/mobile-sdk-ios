//
//  RealtimeUpdateFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/5/19.
//

import Foundation

class RealtimeUpdateFeature {
    static var shared: RealtimeUpdateFeature?
    
    private var controls = NSHashTable<AnyObject>.weakObjects()
    private var socketManger: CrowdinSocketManager!
    private var mappingManager: CrowdinMappingManagerProtocol
    
    init(strings: [String], plurals: [String], hash: String, sourceLanguage: String) {
        self.mappingManager = CrowdinMappingManager(strings: strings, plurals: plurals, hash: hash, sourceLanguage: sourceLanguage)
    }
    
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
            self.subscribe(with: token)
        }
        
        UIApplication.shared.keyWindow?.rootViewController?.present(loginVC, animated: true, completion: { })
    }
    
    func subscribe(with token: String) {
        self.socketManger = CrowdinSocketManager(csrf_token: token)
        self.socketManger.didChangeString = { id, newValue in
            
        }
        
        self.socketManger.didChangeString = { id, newValue in
            
        }
        
        self.socketManger.start()
    }
    
    func didChangeString(with id: Int, to newValue: String) {
        let key = mappingManager.stringLocalizationKey(for: id)
    }
    
    func didChangePlural(with id: Int, to newValue: String) {
        let key = mappingManager.stringLocalizationKey(for: id)
    }
}
