//
//  CountryMappingTests.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import XCTest
@testable import CountriesApp

final class CountryMappingTests: XCTestCase {

    // MARK: - CountryAPIResponse.toDomain()

    func test_toDomain_mapsNameCorrectly() {
        let response = makeResponse(commonName: "Egypt")
        XCTAssertEqual(response.toDomain().name, "Egypt")
    }

    func test_toDomain_mapsAlpha2CodeCorrectly() {
        let response = makeResponse(cca2: "EG")
        XCTAssertEqual(response.toDomain().alpha2Code, "EG")
    }

    func test_toDomain_takesFirstCapital() {
        let response = makeResponse(capitals: ["Cairo", "Alexandria"])
        XCTAssertEqual(response.toDomain().capital, "Cairo")
    }

    func test_toDomain_nilCapital_whenNoCapitals() {
        let response = makeResponse(capitals: nil)
        XCTAssertNil(response.toDomain().capital)
    }

    func test_toDomain_nilCapital_whenEmptyArray() {
        let response = makeResponse(capitals: [])
        XCTAssertNil(response.toDomain().capital)
    }

    func test_toDomain_mapsCurrencyCodeNameSymbol() {
        let response = makeResponse(currencies: ["EGP": ("Egyptian Pound", "£")])
        let currency = response.toDomain().primaryCurrency
        XCTAssertEqual(currency?.code, "EGP")
        XCTAssertEqual(currency?.name, "Egyptian Pound")
        XCTAssertEqual(currency?.symbol, "£")
    }

    func test_toDomain_nilCurrency_whenNoCurrencies() {
        let response = makeResponse(currencies: nil)
        XCTAssertNil(response.toDomain().primaryCurrency)
    }

    func test_toDomain_mapsRegionCorrectly() {
        let response = makeResponse(region: "Africa")
        XCTAssertEqual(response.toDomain().region, "Africa")
    }

    func test_toDomain_mapsPopulationCorrectly() {
        let response = makeResponse(population: 102_334_403)
        XCTAssertEqual(response.toDomain().population, 102_334_403)
    }

    func test_toDomain_flagEmojiDerivedFromAlpha2Code() {
        let response = makeResponse(cca2: "EG")
        XCTAssertEqual(response.toDomain().flagEmoji, "🇪🇬")
    }

    func test_toDomain_idMatchesAlpha2Code() {
        let response = makeResponse(cca2: "FR")
        let country = response.toDomain()
        XCTAssertEqual(country.id, country.alpha2Code)
    }

    // MARK: - Country Equatable / Hashable

    func test_country_equality_basedOnAlpha2Code() {
        let a = MockCountryService.makeCountry(name: "Egypt A", alpha2Code: "EG")
        let b = MockCountryService.makeCountry(name: "Egypt B", alpha2Code: "EG")
        XCTAssertEqual(a, b)
    }

    func test_country_inequality_differentCodes() {
        let egypt = MockCountryService.makeCountry(alpha2Code: "EG")
        let france = MockCountryService.makeCountry(alpha2Code: "FR")
        XCTAssertNotEqual(egypt, france)
    }

    func test_country_hashableInSet() {
        let egypt1 = MockCountryService.makeCountry(name: "Egypt 1", alpha2Code: "EG")
        let egypt2 = MockCountryService.makeCountry(name: "Egypt 2", alpha2Code: "EG")
        let set: Set<Country> = [egypt1, egypt2]
        XCTAssertEqual(set.count, 1)
    }

    // MARK: - Helpers

    private func makeResponse(
        commonName: String = "Egypt",
        cca2: String = "EG",
        capitals: [String]? = ["Cairo"],
        currencies: [String: (String, String)]? = ["EGP": ("Egyptian Pound", "£")],
        region: String? = "Africa",
        population: Int = 100_000_000
    ) -> CountryAPIResponse {
        let currencyMap: [String: CountryAPIResponse.CurrencyAPIResponse]? = currencies?.reduce(into: [:]) { result, pair in
            result[pair.key] = CountryAPIResponse.CurrencyAPIResponse(name: pair.value.0, symbol: pair.value.1)
        }
        return CountryAPIResponse(
            name: CountryAPIResponse.CountryName(common: commonName),
            cca2: cca2,
            capital: capitals,
            currencies: currencyMap,
            region: region,
            population: population
        )
    }
}
