//
//  String+FlagEmoji.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import Foundation

extension String {
    /// Converts an ISO 3166-1 alpha-2 country code (e.g. "EG") to its flag emoji (e.g. 🇪🇬).
    var flagEmoji: String {
        guard self.count == 2 else { return "🏳️" }
        return self.uppercased().unicodeScalars.compactMap {
            Unicode.Scalar($0.value + 127397)
        }.reduce("") { $0 + String($1) }
    }
}