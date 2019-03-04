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
}
