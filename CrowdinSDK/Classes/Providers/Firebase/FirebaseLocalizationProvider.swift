//
//  FirebaseProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/2/19.
//

import Foundation
import FirebaseDatabase

@objcMembers public class FirebaseLocalizationProvider: BaseLocalizationProvider {
    let crowdinFolder = CrowdinFolder.shared
	let firebaseFolder: Folder
    let database: DatabaseReference = Database.database().reference()
    
    public var path: String
    
    public required override init() {
        self.path = "localization"
		self.firebaseFolder = try! crowdinFolder.createFolder(with: "Firebase")
        super.init()
		self.refresh()
        self.subscribe()
    }
    
    public init(path: String) {
        self.path = path
		self.firebaseFolder = try! crowdinFolder.createFolder(with: "Firebase")
        super.init()
		self.refresh()
        self.subscribe()
    }
    
    public required init(localizations: [String], strings: [String : String], plurals: [AnyHashable : Any]) {
        self.path = "localization"
		self.firebaseFolder = try! crowdinFolder.createFolder(with: "Firebase")
        super.init(localizations: localizations, strings: strings, plurals: plurals)
		self.refresh()
        self.subscribe()
    }
    
    public override func set(localization: String?) {
        super.set(localization: localization)
        self.refresh()
    }
    
    func refresh() {
        guard let sdkFile = firebaseFolder.files.filter({ $0.name == localization }).first else { return }
        guard let dictionary = NSDictionary(contentsOfFile: sdkFile.path)  else { return }
        if let strings = dictionary["strings"] as? [String: String] {
            self.set(strings: strings)
        }
        if let plurals = dictionary["plurals"] as? [AnyHashable: Any] {
            self.set(plurals: plurals)
        }
    }
	
    func removeFolders() {
        if crowdinFolder.isCreated { try? crowdinFolder.remove() }
		if firebaseFolder.isCreated { try? firebaseFolder.remove() }
    }
    
    public override func deintegrate() {
        self.removeFolders()
    }
    
    func subscribe() {
        let reference = self.database.child(path)
        reference.observe(DataEventType.value) { (snapshot: DataSnapshot) in
            if var dictionary = snapshot.value as? [String: Any] {
				dictionary = dictionary.decodeFirebase()
				self.localizations = [String](dictionary.keys)
                dictionary.keys.forEach({ (key) in
                    let strings = dictionary[key] as! [String: Any]
                    let stringsFile = DictionaryFile(path: self.firebaseFolder.path + String.pathDelimiter + key + FileType.plist.extension)
                    stringsFile.file = strings
                    try? stringsFile.save()
                })
                self.refresh()
                CrowdinSDK.reloadUI()
			} else {
				// Upload localization.
				self.uploadLocalization()
			}
        }
    }
	
	func uploadLocalization() {
		let json = LocalizationExtractor.extractLocalizationJSON().encodeFirebase()
		let reference = self.database.child(path)
		reference.setValue(json)
	}
}
