//
//  CrowdinSDK.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/24/19.
//

import Foundation

public class CrowdinSDK: NSObject {
    class var localizations: [String] { return Bundle.main.localizations }
    
    public class func start() {
        Bundle.swizzle()
        
        Localization.shared.set(localization: "uk")
        
        print(localizations)
        
        let crowdinFolder = DocumentsFolder(name: Bundle.main.bundleId + ".Crowdin")
        if !crowdinFolder.isCreated { try? crowdinFolder.create() }
        
        localizations.forEach({ _ = try? crowdinFolder.createFolder(with: $0) })
        
        
        
//        guard let path = Bundle.main.path(forResource: "en", ofType: FileType.lproj.extension) else { return }
//        let folder = Folder(path: path)
//        let files = folder.files
//        files.forEach { (file) in
//            let dict = NSDictionary(contentsOf: URL(fileURLWithPath: file.path))
//            print(file.name)
//            print(dict)
//            print("")
//        }
//        print("finish")
    }
    
    public class func deintegrate() {
        
    }
    
    public class func setLocale(_ locale: String) {
        
    }
}
