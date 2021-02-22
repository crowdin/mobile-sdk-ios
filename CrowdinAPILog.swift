//
//  CrowdinAPILog.swift
//  CrowdinSDK
//
//  Created by Nazar Yavornytskyy on 2/16/21.
//

import Foundation
import BaseAPI

extension CrowdinAPI {
    
    func logRequest(
        method: RequestMethod,
        url: String,
        parameters: [String: String]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil,
        responseData: Data? = nil
    ) {
        let urlMethod = method.rawValue
        let message = [urlMethod, url].joined(separator: ", ")
        let attributedText = AttributedTextFormatter.make(
            method: method,
            url: url,
            parameters: parameters,
            headers: headers,
            body: body,
            responseData: responseData
        )
        
        CrowdinLogsCollector.shared.add(log: CrowdinLog.rest(with: message, attributedDetails: attributedText))
    }
}
