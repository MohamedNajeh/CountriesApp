//
//  MainViewModel.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class MainViewModel {

    static let maxCountries = 5
    static let defaultCountryCode = "EG"

    var allCountries: [Country] = []
    var isLoading = false
    var errorMessage: String?
    var isOffline = false

    private let countryService: CountryServiceProtocol
    private let locationService: LocationServiceProtocol

    init(
        countryService: CountryServiceProtocol = CountryService(),
        locationService: LocationServiceProtocol = LocationService()
    ) {
        self.countryService = countryService
        self.locationService = locationService
    }

    // MARK: - Data Loading

    func loadInitialData(modelContext: ModelContext) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let countries = try await countryService.fetchAllCountries()
            allCountries = countries
            isOffline = false
            await autoAddLocationCountry(modelContext: modelContext)
        } catch let urlError as URLError where urlError.code == .notConnectedToInternet {
            isOffline = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func autoAddLocationCountry(modelContext: ModelContext) async {
        guard fetchSaved(modelContext: modelContext).isEmpty else { return }

        let code = await locationService.requestCountryCode()
        let country = countryService.findCountry(byCode: code, in: allCountries)
            ?? countryService.findCountry(byCode: Self.defaultCountryCode, in: allCountries)

        if let country {
            addCountry(country, modelContext: modelContext)
        }
    }

    // MARK: - CRUD

    func addCountry(_ country: Country, modelContext: ModelContext) {
        let existing = fetchSaved(modelContext: modelContext)
        guard existing.count < Self.maxCountries else { return }
        guard !existing.contains(where: { $0.alpha2Code == country.alpha2Code }) else { return }

        let saved = SavedCountry(from: country, order: existing.count)
        modelContext.insert(saved)
        HapticFeedback.impact(.medium)
    }

    func removeCountry(_ savedCountry: SavedCountry, modelContext: ModelContext) {
        modelContext.delete(savedCountry)
        HapticFeedback.impact(.light)
        reorderAfterDeletion(modelContext: modelContext)
    }

    func isAlreadyAdded(_ country: Country, modelContext: ModelContext) -> Bool {
        fetchSaved(modelContext: modelContext)
            .contains(where: { $0.alpha2Code == country.alpha2Code })
    }

    // MARK: - Helpers

    func fetchSaved(modelContext: ModelContext) -> [SavedCountry] {
        let descriptor = FetchDescriptor<SavedCountry>(
            sortBy: [SortDescriptor(\.order)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func reorderAfterDeletion(modelContext: ModelContext) {
        let sorted = fetchSaved(modelContext: modelContext)
        for (index, country) in sorted.enumerated() {
            country.order = index
        }
    }
}