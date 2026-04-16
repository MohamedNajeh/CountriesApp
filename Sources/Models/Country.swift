//
//  Country.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import Foundation

// MARK: - Domain Model (used throughout the app)

struct Country: Identifiable, Hashable {
    let name: String
    let alpha2Code: String
    let capital: String?
    let primaryCurrency: Currency?
    let region: String?
    let population: Int

    var id: String { alpha2Code }
    var flagEmoji: String { alpha2Code.flagEmoji }

    static func == (lhs: Country, rhs: Country) -> Bool {
        lhs.alpha2Code == rhs.alpha2Code
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(alpha2Code)
    }
}

// MARK: - REST Countries v3.1 Decodable DTO

struct CountryAPIResponse: Decodable {
    let name: CountryName
    let cca2: String
    let capital: [String]?
    let currencies: [String: CurrencyAPIResponse]?
    let region: String?
    let population: Int

    struct CountryName: Decodable {
        let common: String
    }

    struct CurrencyAPIResponse: Decodable {
        let name: String?
        let symbol: String?
    }

    func toDomain() -> Country {
        let currency: Currency? = currencies?.first.map { (code, value) in
            Currency(code: code, name: value.name, symbol: value.symbol)
        }
        return Country(
            name: name.common,
            alpha2Code: cca2,
            capital: capital?.first,
            primaryCurrency: currency,
            region: region,
            population: population
        )
    }
}