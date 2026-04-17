//
//  MainViewModelTests.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import XCTest
import SwiftData
@testable import CountriesApp

@MainActor
final class MainViewModelTests: XCTestCase {

    private var viewModel: MainViewModel!
    private var mockCountryService: MockCountryService!
    private var mockLocationService: MockLocationService!
    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        mockCountryService = MockCountryService()
        mockLocationService = MockLocationService()
        viewModel = MainViewModel(
            countryService: mockCountryService,
            locationService: mockLocationService
        )
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: SavedCountry.self, configurations: config)
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() async throws {
        viewModel = nil
        mockCountryService = nil
        mockLocationService = nil
        modelContainer = nil
        modelContext = nil
        try await super.tearDown()
    }

    // MARK: - addCountry

    func test_addCountry_addsSuccessfully() {
        let country = MockCountryService.makeCountry(name: "Egypt", alpha2Code: "EG")

        viewModel.addCountry(country, modelContext: modelContext)

        let saved = viewModel.fetchSaved(modelContext: modelContext)
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.name, "Egypt")
    }

    func test_addCountry_respectsMaxLimit() {
        for i in 0..<6 {
            let country = MockCountryService.makeCountry(
                name: "Country \(i)",
                alpha2Code: String(format: "C%d", i)
            )
            viewModel.addCountry(country, modelContext: modelContext)
        }

        let saved = viewModel.fetchSaved(modelContext: modelContext)
        XCTAssertEqual(saved.count, MainViewModel.maxCountries)
    }

    func test_addCountry_preventsDuplicates() {
        let country = MockCountryService.makeCountry(name: "Egypt", alpha2Code: "EG")

        viewModel.addCountry(country, modelContext: modelContext)
        viewModel.addCountry(country, modelContext: modelContext)

        let saved = viewModel.fetchSaved(modelContext: modelContext)
        XCTAssertEqual(saved.count, 1)
    }

    // MARK: - removeCountry

    func test_removeCountry_removesSuccessfully() {
        let country = MockCountryService.makeCountry(name: "Egypt", alpha2Code: "EG")
        viewModel.addCountry(country, modelContext: modelContext)

        let saved = viewModel.fetchSaved(modelContext: modelContext)
        XCTAssertEqual(saved.count, 1)

        viewModel.removeCountry(saved[0], modelContext: modelContext)

        let afterRemoval = viewModel.fetchSaved(modelContext: modelContext)
        XCTAssertEqual(afterRemoval.count, 0)
    }

    func test_removeCountry_reordersCorrectly() {
        let countries = (0..<3).map {
            MockCountryService.makeCountry(name: "Country \($0)", alpha2Code: "C\($0)")
        }
        countries.forEach { viewModel.addCountry($0, modelContext: modelContext) }

        let saved = viewModel.fetchSaved(modelContext: modelContext)
        viewModel.removeCountry(saved[0], modelContext: modelContext)

        let afterRemoval = viewModel.fetchSaved(modelContext: modelContext)
        XCTAssertEqual(afterRemoval.count, 2)
        XCTAssertEqual(afterRemoval[0].order, 0)
        XCTAssertEqual(afterRemoval[1].order, 1)
    }

    // MARK: - isAlreadyAdded

    func test_isAlreadyAdded_returnsTrueForExistingCountry() {
        let country = MockCountryService.makeCountry(name: "Egypt", alpha2Code: "EG")
        viewModel.addCountry(country, modelContext: modelContext)

        XCTAssertTrue(viewModel.isAlreadyAdded(country, modelContext: modelContext))
    }

    func test_isAlreadyAdded_returnsFalseForNewCountry() {
        let country = MockCountryService.makeCountry(name: "France", alpha2Code: "FR")

        XCTAssertFalse(viewModel.isAlreadyAdded(country, modelContext: modelContext))
    }

    // MARK: - loadInitialData (GPS / fallback)

    func test_loadInitialData_locationDenied_defaultsToEgypt() async {
        let egypt = MockCountryService.makeCountry(name: "Egypt", alpha2Code: "EG")
        mockCountryService.stubbedCountries = [egypt]
        mockLocationService.stubbedCountryCode = "EG"

        await viewModel.loadInitialData(modelContext: modelContext)

        let saved = viewModel.fetchSaved(modelContext: modelContext)
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.alpha2Code, "EG")
    }

    func test_loadInitialData_gpsResolved_addsDetectedCountry() async {
        let egypt = MockCountryService.makeCountry(name: "Egypt", alpha2Code: "EG")
        let france = MockCountryService.makeCountry(name: "France", alpha2Code: "FR")
        mockCountryService.stubbedCountries = [egypt, france]
        mockLocationService.stubbedCountryCode = "FR"

        await viewModel.loadInitialData(modelContext: modelContext)

        let saved = viewModel.fetchSaved(modelContext: modelContext)
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.alpha2Code, "FR")
    }

    func test_loadInitialData_doesNotAutoAddIfCountriesExist() async {
        // Pre-populate one country so auto-add should skip
        let existing = MockCountryService.makeCountry(name: "Germany", alpha2Code: "DE")
        viewModel.addCountry(existing, modelContext: modelContext)

        let egypt = MockCountryService.makeCountry(name: "Egypt", alpha2Code: "EG")
        mockCountryService.stubbedCountries = [egypt]
        mockLocationService.stubbedCountryCode = "EG"

        await viewModel.loadInitialData(modelContext: modelContext)

        let saved = viewModel.fetchSaved(modelContext: modelContext)
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.alpha2Code, "DE")
    }

    func test_loadInitialData_setsIsOffline_onNetworkError() async {
        mockCountryService.shouldThrow = URLError(.notConnectedToInternet)

        await viewModel.loadInitialData(modelContext: modelContext)

        XCTAssertTrue(viewModel.isOffline)
    }
}