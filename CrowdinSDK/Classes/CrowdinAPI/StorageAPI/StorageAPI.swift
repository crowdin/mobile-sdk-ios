//
//  StorageAPI.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 5/8/19.
//

import Foundation
import BaseAPI

class StorageAPI: CrowdinAPI {
    override var apiPath: String {
        return "storages"
    }
    
    func uploadNewFile(data: Data, completion: @escaping (StorageUploadResponse?, Error?) -> Void) {
        let headers = [RequestHeaderFields.contentType.rawValue: "image/png"]
        self.cw_post(url: fullPath, headers: headers, body: data, completion: completion)
    }
}
