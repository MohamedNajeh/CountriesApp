//
//  SearchViewModel.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import Foundation
import Observation

@Observable
final class SearchViewModel {

    var searchText: String = ""
    var filteredCountries: [Country] = []
    var isSearching = false

    private var debounceTask: Task<Void, Never>?

    func search(query: String, in countries: [Country]) {
        debounceTask?.cancel()
        debounceTask = Task {
            // 300 ms debounce
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }

            let result = performFilter(query: query, in: countries)
            await MainActor.run {
                self.filteredCountries = result
                self.isSearching = false
            }
        }
        isSearching = !query.isEmpty
    }

    private func performFilter(query: String, in countries: [Country]) -> [Country] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return countries
        }
        let lowercased = query.lowercased()
        return countries.filter { country in
            country.name.lowercased().contains(lowercased)
            || (country.capital?.lowercased().contains(lowercased) ?? false)
            || (country.primaryCurrency?.name?.lowercased().contains(lowercased) ?? false)
            || (country.primaryCurrency?.code?.lowercased().contains(lowercased) ?? false)
        }
    }
}