//
//  SearchViewModelTests.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import XCTest
@testable import CountriesApp

@MainActor
final class SearchViewModelTests: XCTestCase {

    private var viewModel: SearchViewModel!

    private let sampleCountries: [Country] = [
        MockCountryService.makeCountry(name: "Egypt", alpha2Code: "EG", capital: "Cairo", currencyCode: "EGP", currencyName: "Egyptian Pound"),
        MockCountryService.makeCountry(name: "France", alpha2Code: "FR", capital: "Paris", currencyCode: "EUR", currencyName: "Euro"),
        MockCountryService.makeCountry(name: "Japan", alpha2Code: "JP", capital: "Tokyo", currencyCode: "JPY", currencyName: "Japanese Yen"),
        MockCountryService.makeCountry(name: "United States", alpha2Code: "US", capital: "Washington D.C.", currencyCode: "USD", currencyName: "United States Dollar")
    ]

    override func setUp() {
        super.setUp()
        viewModel = SearchViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Search by name

    func test_search_byName_returnsMatchingCountry() async throws {
        viewModel.search(query: "Egypt", in: sampleCountries)
        try await Task.sleep(nanoseconds: 400_000_000) // wait for debounce

        XCTAssertEqual(viewModel.filteredCountries.count, 1)
        XCTAssertEqual(viewModel.filteredCountries.first?.name, "Egypt")
    }

    func test_search_byNamePartial_returnsMatchingCountries() async throws {
        viewModel.search(query: "an", in: sampleCountries)
        try await Task.sleep(nanoseconds: 400_000_000)

        // "Japan" and "United States" contain "an" — France does not, Egypt does not
        let names = viewModel.filteredCountries.map(\.name)
        XCTAssertTrue(names.contains("Japan"))
    }

    // MARK: - Search by capital

    func test_search_byCapital_returnsCairoAsEgypt() async throws {
        viewModel.search(query: "Cairo", in: sampleCountries)
        try await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertEqual(viewModel.filteredCountries.count, 1)
        XCTAssertEqual(viewModel.filteredCountries.first?.alpha2Code, "EG")
    }

    func test_search_byCapital_Tokyo_returnsJapan() async throws {
        viewModel.search(query: "Tokyo", in: sampleCountries)
        try await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertEqual(viewModel.filteredCountries.first?.name, "Japan")
    }

    // MARK: - Search by currency

    func test_search_byCurrencyName_returnsCorrectCountry() async throws {
        viewModel.search(query: "Euro", in: sampleCountries)
        try await Task.sleep(nanoseconds: 400_000_000)

        let names = viewModel.filteredCountries.map(\.name)
        XCTAssertTrue(names.contains("France"))
    }

    func test_search_byCurrencyCode_returnsCorrectCountry() async throws {
        viewModel.search(query: "JPY", in: sampleCountries)
        try await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertEqual(viewModel.filteredCountries.first?.name, "Japan")
    }

    // MARK: - Empty query

    func test_search_emptyQuery_returnsAllCountries() async throws {
        viewModel.search(query: "", in: sampleCountries)
        try await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertEqual(viewModel.filteredCountries.count, sampleCountries.count)
    }

    func test_search_whitespaceOnlyQuery_returnsAllCountries() async throws {
        viewModel.search(query: "   ", in: sampleCountries)
        try await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertEqual(viewModel.filteredCountries.count, sampleCountries.count)
    }

    // MARK: - No results

    func test_search_unmatchedQuery_returnsEmpty() async throws {
        viewModel.search(query: "zzzznonexistent", in: sampleCountries)
        try await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertTrue(viewModel.filteredCountries.isEmpty)
    }

    // MARK: - Case insensitivity

    func test_search_caseInsensitive_returnsResults() async throws {
        viewModel.search(query: "EGYPT", in: sampleCountries)
        try await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertEqual(viewModel.filteredCountries.first?.name, "Egypt")
    }
}