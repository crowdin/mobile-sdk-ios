//
//  AttributedTextFormatter.swift
//  CrowdinSDK
//
//  Created by Nazar Yavornytskyy on 2/19/21.
//

import Foundation
import BaseAPI

enum AttributedTextFormatter {
   
    static func make(
        method: RequestMethod,
        url: String,
        parameters: [String: String]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil,
        responseData: Data? = nil
    ) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()
        
        [
            AttributeFactory.make(.method(method.rawValue)),
            AttributeFactory.make(.separator),
            AttributeFactory.make(.url(url)),
            AttributeFactory.make(.separator),
            AttributeFactory.make(.parameters(parameters)),
            AttributeFactory.make(.separator),
            AttributeFactory.make(.headers(headers)),
            AttributeFactory.make(.separator),
            AttributeFactory.make(.requestBody(body)),
            AttributeFactory.make(.separator),
            AttributeFactory.make(.responseBody(responseData))
        ].forEach {
            attributedText.append($0)
        }
        
        return attributedText
    }
}

enum Attribute {
    
    case url(String)
    case method(String)
    case parameters([String: String]?)
    case headers([String: String]?)
    case requestBody(Data?)
    case responseBody(Data?)
    case newLine
    case separator
    
    var title: String {
        switch self {
        case .url:
            return "[URL]"
        case .method:
            return "[Method]"
        case .parameters:
            return "[Parameters]"
        case .headers:
            return "[Headers]"
        case .requestBody:
            return "[Request Body]"
        case .responseBody:
            return "[Response Body]"
        default:
            return ""
        }
    }
}