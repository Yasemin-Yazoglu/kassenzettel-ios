//
//  AppConfig.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 25.10.26.
//

import Foundation

enum AppConfig {
    static let supabaseURL: URL = {
        let host = value(for: "SUPABASE_HOST")
        guard let url = URL(string: "https://\(host)") else {
            fatalError("SUPABASE_HOST is not a valid host: \(host)")
        }
        return url
    }()

    static let supabasePublishableKey: String = value(for: "SUPABASE_PUBLISHABLE_KEY")

    private static func value(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty else {
            fatalError("Missing \(key). Check the .xcconfig files in Config/.")
        }
        return value
    }
}
