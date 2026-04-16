//
//  MainView.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import SwiftUI
import SwiftData

struct MainView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedCountry.order) private var savedCountries: [SavedCountry]

    @State private var viewModel = MainViewModel()
    @State private var showSearch = false
    @State private var selectedCountry: SavedCountry?
    @State private var hasLoadedOnce = false

    private var emptySlotCount: Int {
        max(0, MainViewModel.maxCountries - savedCountries.count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        headerView
                        offlineBanner
                        contentArea
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedCountry) { country in
                CountryDetailView(country: country)
            }
            .sheet(isPresented: $showSearch) {
                SearchView(
                    allCountries: viewModel.allCountries,
                    onSelect: { country in
                        viewModel.addCountry(country, modelContext: modelContext)
                        showSearch = false
                    },
                    isAlreadyAdded: { country in
                        viewModel.isAlreadyAdded(country, modelContext: modelContext)
                    },
                    isFull: savedCountries.count >= MainViewModel.maxCountries
                )
            }
            .task {
                guard !hasLoadedOnce else { return }
                hasLoadedOnce = true
                await viewModel.loadInitialData(modelContext: modelContext)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Image(systemName: "globe.americas.fill")
                        .font(.title2)
                        .foregroundStyle(Color.accentBlue)
                    Text("Countries")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                Text("Your world at a glance")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            countBadge
        }
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    private var countBadge: some View {
        Text("\(savedCountries.count)/\(MainViewModel.maxCountries)")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(savedCountries.count >= MainViewModel.maxCountries ? Color.accentPurple : Color.accentBlue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.cardSurface)
                    .overlay(
                        Capsule()
                            .stroke(
                                savedCountries.count >= MainViewModel.maxCountries ? Color.accentPurple.opacity(0.5) : Color.accentBlue.opacity(0.4),
                                lineWidth: 1
                            )
                    )
            )
    }

    @ViewBuilder
    private var offlineBanner: some View {
        if viewModel.isOffline {
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .font(.caption)
                Text("Offline — showing saved data")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.accentPurple.opacity(0.25))
                    .overlay(Capsule().stroke(Color.accentPurple.opacity(0.4), lineWidth: 1))
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading && savedCountries.isEmpty {
            LoadingSkeletonView()
                .transition(.opacity)
        } else {
            VStack(spacing: 14) {
                ForEach(savedCountries) { country in
                    CountryCardView(country: country) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            viewModel.removeCountry(country, modelContext: modelContext)
                        }
                    }
                    .onTapGesture {
                        selectedCountry = country
                    }
                }

                ForEach(0..<emptySlotCount, id: \.self) { _ in
                    EmptySlotCardView {
                        showSearch = true
                    }
                    .transition(.opacity)
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: savedCountries.count)
        }
    }
}