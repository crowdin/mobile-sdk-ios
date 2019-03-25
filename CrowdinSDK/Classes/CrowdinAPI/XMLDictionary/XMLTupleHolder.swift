//
//  XMLTupleHolder.swift
//  XMLDictionary
//
//  Created by Volker Bublitz on 23/02/2017.
//
//

import Foundation

class XMLTupleHolder: NSObject {

    var dict:[String:Any]
    
    init(_ dict:[String:Any]) {
        self.dict = dict
    }
    
    func resolvedDictionary() -> [String : Any] {
        var result:[String:Any] = [:]
        for (key, value) in self.dict {
            if let tuple = value as? XMLTupleHolder {
                result[key] = tuple.resolvedDictionary()
            }
            else if let array = value as? XMLArrayHolder {
                result[key] = array.resolvedArray()
            }
            else {
                result[key] = value
            }
        }
        return result
    }
    
    subscript(key: String) -> Any? {
        get {
            return self.dict[key]
        }
        set {
            self.dict[key] = newValue
        }
    }
    
}
