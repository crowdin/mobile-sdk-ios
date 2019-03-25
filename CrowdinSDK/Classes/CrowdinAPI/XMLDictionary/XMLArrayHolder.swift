//
//  XMLArrayHolder.swift
//  XMLDictionary
//
//  Created by Volker Bublitz on 23/02/2017.
//
//

import Foundation

class XMLArrayHolder: NSObject {
    
    var array:[Any]
    
    var count:Int {
        return self.array.count
    }
    
    init(_ array:[Any]) {
        self.array = array
    }
    
    func resolvedArray() -> [Any] {
        var result:[Any] = []
        for value in self.array {
            if let tuple = value as? XMLTupleHolder {
                result.append(tuple.resolvedDictionary())
            }
            else if let array = value as? XMLArrayHolder {
                result.append(array.resolvedArray())
            }
            else {
                result.append(value)
            }
        }
        return result
    }
    
    func removeLast() {
        self.array.removeLast()
    }

    func append(_ item:Any) {
        self.array.append(item)
    }
    
    func insert(_ element:Any, at:Int) {
        self.array.insert(element, at: at)
    }
    
    subscript(key:Int) -> Any {
        get {
            return self.array[key]
        }
        set {
            self.array[key] = newValue
        }
    }
    
}
