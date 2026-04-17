//
//  MockCountryService.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import Foundation
@testable import CountriesApp

final class MockCountryService: CountryServiceProtocol {

    var stubbedCountries: [Country] = []
    var shouldThrow: Error?
    var fetchCallCount = 0

    func fetchAllCountries() async throws -> [Country] {
        fetchCallCount += 1
        if let error = shouldThrow {
            throw error
        }
        return stubbedCountries
    }

    func findCountry(byCode alpha2Code: String, in countries: [Country]) -> Country? {
        countries.first { $0.alpha2Code.uppercased() == alpha2Code.uppercased() }
    }

    // MARK: - Factory

    static func makeCountry(
        name: String = "Test Country",
        alpha2Code: String = "TC",
        capital: String? = "Test Capital",
        currencyCode: String? = "TST",
        currencyName: String? = "Test Dollar",
        currencySymbol: String? = "$",
        region: String? = "Test Region",
        population: Int = 1_000_000
    ) -> Country {
        let currency = Currency(code: currencyCode, name: currencyName, symbol: currencySymbol)
        return Country(
            name: name,
            alpha2Code: alpha2Code,
            capital: capital,
            primaryCurrency: currency,
            region: region,
            population: population
        )
    }
}