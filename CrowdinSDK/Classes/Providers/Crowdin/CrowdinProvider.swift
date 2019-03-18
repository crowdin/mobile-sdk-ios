//
//  CrowdinProvider.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 2/2/19.
//

import Foundation

public class CrowdinProvider: BaseLocalizationProvider {
    var hashString: String
    var stringsFileNames: [String] = []
    var pluralsFileNames: [String] = []
    let crowdinAPI: CrowdinAPI
    fileprivate let downloadOperationQueue = OperationQueue()
    
    public override init() {
        guard let hashString = Bundle.main.crowdinHash else {
            fatalError("Please add CrowdinHash key to your Info.plist file")
        }
        guard let crowdinStringsFileNames = Bundle.main.crowdinStringsFileNames else {
            fatalError("Please add CrowdinStringsFileNames key to your Info.plist file")
        }
        guard let crowdinPluralsFileNames = Bundle.main.crowdinPluralsFileNames else {
            fatalError("Please add CrowdinPluralsFileNames key to your Info.plist file")
        }
        self.hashString = hashString
        self.crowdinAPI = CrowdinAPI(hash: hashString)
        self.stringsFileNames = crowdinStringsFileNames
        self.pluralsFileNames = crowdinPluralsFileNames
        super.init()
        self.downloadLocalization()
    }
    
    public required init(localizations: [String], strings: [String : String], plurals: [AnyHashable : Any]) {
        fatalError("init(localizations:strings:plurals:) has not been implemented")
    }
    
    func downloadLocalization() {
        self.stringsFileNames.forEach { (fileName) in
            let blockOperation = BlockAsyncOperation(block: {
                self.crowdinAPI.getStrings(file: fileName, for: self.localization, completion: { (strings, error) in
                    guard let strings = strings else { return }
                    self.strings += strings
                    self.set(strings: self.strings)
                })
            })
            downloadOperationQueue.addOperation(blockOperation)
        }
        self.pluralsFileNames.forEach { (fileName) in
            let blockOperation = BlockAsyncOperation(block: {
                self.crowdinAPI.getPlurals(file: fileName, for: self.localization, completion: { (plurals, error) in
                    guard let plurals = plurals else { return }
                    self.plurals += plurals
                    self.set(plurals: self.plurals)
                })
            })
            downloadOperationQueue.addOperation(blockOperation)
        }
    }
}
