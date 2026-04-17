//
//  SavedCountryTests.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import XCTest
import SwiftData
@testable import CountriesApp

final class SavedCountryTests: XCTestCase {

    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: SavedCountry.self, configurations: config)
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        try await super.tearDown()
    }

    // MARK: - Initialisation

    func test_init_mapsAllFieldsFromCountry() {
        let country = MockCountryService.makeCountry(
            name: "Egypt",
            alpha2Code: "EG",
            capital: "Cairo",
            currencyCode: "EGP",
            currencyName: "Egyptian Pound",
            currencySymbol: "£",
            region: "Africa",
            population: 102_334_403
        )

        let saved = SavedCountry(from: country, order: 0)

        XCTAssertEqual(saved.name, "Egypt")
        XCTAssertEqual(saved.alpha2Code, "EG")
        XCTAssertEqual(saved.capital, "Cairo")
        XCTAssertEqual(saved.currencyCode, "EGP")
        XCTAssertEqual(saved.currencyName, "Egyptian Pound")
        XCTAssertEqual(saved.currencySymbol, "£")
        XCTAssertEqual(saved.region, "Africa")
        XCTAssertEqual(saved.population, 102_334_403)
        XCTAssertEqual(saved.order, 0)
    }

    func test_init_setsOrderCorrectly() {
        let country = MockCountryService.makeCountry()
        let saved = SavedCountry(from: country, order: 3)
        XCTAssertEqual(saved.order, 3)
    }

    func test_init_setsAddedDateToNow() {
        let before = Date()
        let saved = SavedCountry(from: MockCountryService.makeCountry(), order: 0)
        let after = Date()
        XCTAssertTrue(saved.addedDate >= before && saved.addedDate <= after)
    }

    // MARK: - Computed properties

    func test_flagEmoji_derivedFromAlpha2Code() {
        let country = MockCountryService.makeCountry(alpha2Code: "EG")
        let saved = SavedCountry(from: country, order: 0)
        XCTAssertEqual(saved.flagEmoji, "🇪🇬")
    }

    func test_currencyDisplay_symbolAndCode() {
        let country = MockCountryService.makeCountry(currencyCode: "EGP", currencySymbol: "£")
        let saved = SavedCountry(from: country, order: 0)
        XCTAssertEqual(saved.currencyDisplay, "£ · EGP")
    }

    func test_currencyDisplay_missingSymbol_showsCodeOnly() {
        let country = MockCountryService.makeCountry(currencyCode: "EGP", currencySymbol: nil)
        let saved = SavedCountry(from: country, order: 0)
        XCTAssertEqual(saved.currencyDisplay, "EGP")
    }

    func test_currencyDisplay_bothNil_returnsEmpty() {
        let country = MockCountryService.makeCountry(currencyCode: nil, currencySymbol: nil)
        let saved = SavedCountry(from: country, order: 0)
        XCTAssertEqual(saved.currencyDisplay, "")
    }

    // MARK: - SwiftData persistence

    func test_savedCountry_persistsAndFetches() throws {
        let country = MockCountryService.makeCountry(name: "Egypt", alpha2Code: "EG")
        let saved = SavedCountry(from: country, order: 0)
        modelContext.insert(saved)

        let descriptor = FetchDescriptor<SavedCountry>()
        let results = try modelContext.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Egypt")
    }

    func test_savedCountry_deletesCorrectly() throws {
        let country = MockCountryService.makeCountry(name: "Egypt", alpha2Code: "EG")
        let saved = SavedCountry(from: country, order: 0)
        modelContext.insert(saved)
        modelContext.delete(saved)

        let descriptor = FetchDescriptor<SavedCountry>()
        let results = try modelContext.fetch(descriptor)

        XCTAssertTrue(results.isEmpty)
    }
}
