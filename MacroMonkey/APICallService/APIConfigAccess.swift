//
//  APIConfigAccess.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/17/24.
//

import Foundation


enum ConfigError: Error {
    case missingFile
    case dataReadingFailed
    case missingKey
    case invalidFormat
}

class Config {
    static func apiKey() throws -> String {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist") else {
            throw ConfigError.missingFile
        }
        guard let data = try? Data(contentsOf: url) else {
            throw ConfigError.dataReadingFailed
        }
        guard let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
              let apiKey = result["APIKEY"] as? String else {
            throw ConfigError.invalidFormat
        }
        return apiKey
    }
}
