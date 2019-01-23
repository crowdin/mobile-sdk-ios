//
//  Bundle+Decode.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 1/24/19.
//

import Foundation

extension Bundle {
    func decodeJSON<T: Decodable>(_ type: T.Type, from fileName: String) -> T {
        guard let json = url(forResource: fileName, withExtension: nil) else {
            fatalError("Fail to locate \(fileName) in app bundle.")
        }
        guard let data = try? Data(contentsOf: json) else {
            fatalError("Fail to load \(fileName) in app bundle.")
        }
        guard let result = try? JSONDecoder().decode(T.self, from: data) else {
            fatalError("Fail to decode \(fileName) in app bundle.")
        }
        return result
    }
    
    func encodeJSON<T: Encodable>(_ json: T, to filePath: String) {
        guard let data = try? JSONEncoder().encode(json) else {
            fatalError("Fail to encode \(json).")
        }
        let url = URL(fileURLWithPath: filePath)
        do {
            try data.write(to: url)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
