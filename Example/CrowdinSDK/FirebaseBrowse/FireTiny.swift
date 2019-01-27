//
//  FireTiny.swift
//  Browse
//
//  Created by Robby on 8/11/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import FirebaseDatabase

enum JSONDataType {
	case isBool, isInt, isFloat, isString, isArray, isDictionary, isURL, isNULL
	// isURL is a special kind of string, kind of weird design i know, but it ends up being helpful
}
func stringForType(_ dataType:JSONDataType) -> String{
	switch dataType {
	case .isNULL: return "NULL"
	case .isBool: return "Bool"
	case .isInt: return "Int"
	case .isFloat: return "Float"
	case .isURL: return "URL"
	case .isString: return "String"
	case .isDictionary: return "Dictionary"
	case .isArray: return "Array"
	}
}

class FireTiny {
	static let shared = FireTiny()
	let database: DatabaseReference = Database.database().reference()
	
	fileprivate init() { }
	
	// childURL = nil returns the root of the database
	// childURL can contain multiple subdirectories separated with a slash: "one/two/three"
	func getData(_ childURL:String?, completionHandler: @escaping (Any?) -> ()) {
		var reference = self.database
		if let url = childURL{
			reference = self.database.child(url)
		}
		reference.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			completionHandler(snapshot.value)
		}
	}
	
    // childURL = nil returns the root of the database
    // childURL can contain multiple subdirectories separated with a slash: "one/two/three"
    func subscribe(_ childURL:String?, completionHandler: @escaping (Any?) -> ()) {
        var reference = self.database
        if let url = childURL{
            reference = self.database.child(url)
        }
        reference.observe(DataEventType.value) { (snapshot: DataSnapshot) in
            completionHandler(snapshot.value)
        }
    }
	
	func doesDataExist(at path:String, completionHandler: @escaping (_ doesExist:Bool, _ dataType:JSONDataType, _ data:Any?) -> ()) {
		database.child(path).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
			if let data = snapshot.value {
				completionHandler(true, self.typeOf(FirebaseData: data), data)
			} else{
				completionHandler(false, .isNULL, nil)
			}
		}
	}
	
	func typeOf(FirebaseData object:Any) -> JSONDataType {
		if object is NSNumber {
			let nsnum = object as! NSNumber
			let boolID = CFBooleanGetTypeID() // the type ID of CFBoolean
			let numID = CFGetTypeID(nsnum) // the type ID of num
			if numID == boolID{
				return .isBool
			}
			if nsnum.floatValue == Float(nsnum.intValue){
				return .isInt
			}
			return .isFloat
		} else if object is String {
			if let url: URL = URL(string: object as! String) {
				if UIApplication.shared.canOpenURL(url){
					return .isURL
				} else{
					return .isString
				}
			} else{
				return .isString
			}
		} else if object is NSArray || object is NSMutableArray{
			return .isArray
		} else if object is NSDictionary || object is NSMutableDictionary{
			return .isDictionary
		}
		return .isNULL
	}
}
