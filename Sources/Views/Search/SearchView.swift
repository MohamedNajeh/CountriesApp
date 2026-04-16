//
//  SearchView.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import SwiftUI

struct SearchView: View {

    let allCountries: [Country]
    let onSelect: (Country) -> Void
    let isAlreadyAdded: (Country) -> Bool
    let isFull: Bool

    @State private var searchViewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool
    @Environment(\.dismiss) private var dismiss

    private var displayedCountries: [Country] {
        searchViewModel.searchText.isEmpty ? allCountries : searchViewModel.filteredCountries
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    if isFull {
                        fullBanner
                    }

                    searchBar

                    if searchViewModel.isSearching {
                        ProgressView()
                            .tint(Color.accentBlue)
                            .padding(.top, 40)
                        Spacer()
                    } else if displayedCountries.isEmpty {
                        emptyState
                    } else {
                        countryList
                    }
                }
            }
            .navigationTitle("Search Countries")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.accentBlue)
                }
            }
            .onAppear {
                isSearchFocused = true
                searchViewModel.search(query: "", in: allCountries)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.appBackground)
    }

    // MARK: - Subviews

    private var fullBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.accentPurple)
            Text("Maximum of 5 countries reached. Remove one to add another.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentPurple.opacity(0.15))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.accentPurple.opacity(0.3)),
            alignment: .bottom
        )
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.textSecondary)

            TextField("Country, capital, or currency…", text: $searchViewModel.searchText)
                .foregroundStyle(.white)
                .tint(Color.accentBlue)
                .focused($isSearchFocused)
                .autocorrectionDisabled()
                .onChange(of: searchViewModel.searchText) { _, newValue in
                    searchViewModel.search(query: newValue, in: allCountries)
                }

            if !searchViewModel.searchText.isEmpty {
                Button {
                    searchViewModel.searchText = ""
                    searchViewModel.search(query: "", in: allCountries)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(12)
        .background(Color.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var countryList: some View {
        List(displayedCountries) { country in
            CountryRowView(
                country: country,
                isAdded: isAlreadyAdded(country)
            )
            .listRowBackground(Color.cardSurface.opacity(0.4))
            .listRowSeparatorTint(Color.cardBorder)
            .contentShape(Rectangle())
            .onTapGesture {
                guard !isAlreadyAdded(country), !isFull else { return }
                HapticFeedback.impact(.medium)
                onSelect(country)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(Color.textSecondary)
            Text("No results for \"\(searchViewModel.searchText)\"")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
            Spacer()
        }
    }
}