//
//  Dictionary.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/31/19.
//

import Foundation

extension Dictionary {
	mutating func merge(with dict: [Key: Value]) {
		for (k, v) in dict {
			updateValue(v, forKey: k)
		}
	}
	
	static func += (left: inout [Key: Value], right: [Key: Value]) {
		for (k, v) in right {
			left[k] = v
		}
	}
	
	static func + (left: inout [Key: Value], right: [Key: Value]) -> [Key: Value] {
		var result: [Key: Value] = [:]
		for (k, v) in right {
			result[k] = v
		}
		for (k, v) in left {
			result[k] = v
		}
		return result
	}
}

private protocol Mergable {
    func mergeWithSame<T>(right: T) -> T?
}

public extension Dictionary {
    /**
    Merge Dictionaries
    - Parameter right:  Source dictionary with values to be merged
    - Returns: Merged dictionay
    */
    func merge(right: Dictionary) -> Dictionary {
        var merged = self
        for (k, rv) in right {
            // case of existing left value
            if let lv = self[k] {
                if let lv = lv as? Mergable, let rv = rv as? Mergable, type(of: lv) == type(of: rv) {
                    let m = lv.mergeWithSame(right: rv)
                    merged[k] = m as? Value
                } else {
                    merged[k] = rv
                }
            } else { // case of no existing value
                merged[k] = rv
            }
        }

        return merged
    }
}
extension Array: Mergable {
    func mergeWithSame<T>(right: T) -> T? {
        if let right = right as? Array {
            return (self + right) as? T
        }
        assert(false)
        return nil
    }
}

extension Dictionary: Mergable {
    func mergeWithSame<T>(right: T) -> T? {
        if let right = right as? Dictionary {
            return self.merge(right: right) as? T
        }
        assert(false)
        return nil
    }
}

extension Set: Mergable {
    func mergeWithSame<T>(right: T) -> T? {
        if let right = right as? Set {
            return self.union(right) as? T
        }
        assert(false)
        return nil
    }
}
