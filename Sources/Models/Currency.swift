//
//  Currency.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import Foundation

struct Currency: Codable, Hashable {
    let code: String?
    let name: String?
    let symbol: String?

    var displayText: String {
        let parts = [symbol, code].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.joined(separator: " · ")
    }
}