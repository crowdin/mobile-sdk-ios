//
//  ViewController.swift
//  Browse
//
//  Created by Robby on 8/10/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

class TableViewController: BaseMenuTableVC {
	
	// if tableview's datasource is a DICTIONARY:
	//    it populates its rows with its KEYS
	// if datasource is ARRAY
	//    it populates with array (indexPath row numbers)
	
	var keyArray : [String]?  // only used if dataSource is a DICTIONARY
	
	// the DATA SOURCE
	var data: Any? {
		didSet{
			if let d = self.data as? [String:Any]{
				self.keyArray = Array(d.keys)
			}
			if let d = self.data{
				self.title = stringForType(FireTiny.shared.typeOf(FirebaseData: d))
			}
		}
	}
	
	var address: URL?  // database location, shows up as titleForHeader
	
	func dataIsArray() -> Bool {
		return self.data is [Any]
	}
	func dataIsDictionary() -> Bool {
		return self.data is [String:Any]
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if self.data != nil{
			return 1
		}
		return 0
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let isArray = self.data as? [Any]{
			return isArray.count
		}
		if dataIsDictionary(){
			if let keys = self.keyArray{
				return keys.count
			}
		}
		return 0
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if let url = self.address{
			return url.absoluteString
		}
		return nil
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "tableCell")
		var text: String = ""
		var detailText: String = ""
		var rowObject: Any?
		
		if(dataIsArray()){
			text = String(indexPath.row)
			let dataArray = self.data! as! [AnyObject]
			rowObject = dataArray[indexPath.row]
		}
		if let isDictionary = self.data as? [String:Any]{
			if let keys = keyArray{
				text = String(keys[indexPath.row])
				rowObject = isDictionary[ keys[indexPath.row] ]
			}
		}
		
		if let object = rowObject{
			let type = FireTiny.shared.typeOf(FirebaseData: object)
			switch type{
			case .isArray, .isDictionary:
				detailText = stringForType(type)
			default:
				detailText = String(describing: object)
			}
		}
		cell.textLabel?.text = text
		cell.detailTextLabel?.text = detailText
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var object:Any?
		var objectAddress:String = ""
		
		// depending on DICTIONARY or ARRAY, let's grab the next object to show
		if let isArray = self.data as? [Any]{
			object = isArray[indexPath.row]
			objectAddress = String(indexPath.row)
		}
		if let isDictionary = self.data as? [String:Any]{
			if let keys = keyArray{
				let key: String = keys[indexPath.row]
				object = isDictionary[ key ]
				objectAddress = key
			}
		}
		
		if let obj = object{
			let nextType = FireTiny.shared.typeOf(FirebaseData: obj)
			switch nextType{
			case .isArray, .isDictionary:
				let vc: TableViewController = TableViewController()
				vc.data = obj
				vc.address = self.address?.appendingPathComponent(objectAddress)
				self.navigationController?.pushViewController(vc, animated: true)
			default:
				// leaf (last level down)
				let vc: ObjectViewController = ObjectViewController()
				vc.data = obj
				self.navigationController?.pushViewController(vc, animated: true)
			}
		}
	}
}

