//
//  CountryDetailView.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import SwiftUI

struct CountryDetailView: View {

    let country: SavedCountry
    @State private var cardsAppeared = false

    var body: some View {
        ZStack {
            AnimatedGradientBackground()

            ScrollView {
                VStack(spacing: 24) {
                    heroSection
                    infoGrid
                    Spacer(minLength: 30)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                cardsAppeared = true
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 16) {
            Text(country.flagEmoji)
                .font(.system(size: 100))
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                .scaleEffect(cardsAppeared ? 1 : 0.6)
                .opacity(cardsAppeared ? 1 : 0)
                .animation(.spring(response: 0.55, dampingFraction: 0.7), value: cardsAppeared)

            VStack(spacing: 6) {
                Text(country.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                if let region = country.region, !region.isEmpty {
                    Text(region)
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 32)
        .padding(.horizontal, 24)
    }

    // MARK: - Info Grid

    private var infoGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 14
        ) {
            InfoCard(
                icon: "mappin.circle.fill",
                iconColor: .accentBlue,
                title: "Capital City",
                value: country.capital ?? "—",
                delay: 0.05
            )
            .opacity(cardsAppeared ? 1 : 0)
            .offset(y: cardsAppeared ? 0 : 20)

            InfoCard(
                icon: "banknote.fill",
                iconColor: .accentPurple,
                title: "Currency",
                value: country.currencyName ?? "—",
                subtitle: country.currencyDisplay.isEmpty ? nil : country.currencyDisplay,
                delay: 0.1
            )
            .opacity(cardsAppeared ? 1 : 0)
            .offset(y: cardsAppeared ? 0 : 20)

            InfoCard(
                icon: "globe.europe.africa.fill",
                iconColor: Color(hex: "#FF9500"),
                title: "Region",
                value: country.region ?? "—",
                delay: 0.15
            )
            .opacity(cardsAppeared ? 1 : 0)
            .offset(y: cardsAppeared ? 0 : 20)

            InfoCard(
                icon: "person.3.fill",
                iconColor: Color(hex: "#34C759"),
                title: "Population",
                value: country.population.formattedPopulation,
                delay: 0.2
            )
            .opacity(cardsAppeared ? 1 : 0)
            .offset(y: cardsAppeared ? 0 : 20)
        }
        .padding(.horizontal, 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: cardsAppeared)
    }
}

// MARK: - Info Card

private struct InfoCard: View {

    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    var subtitle: String? = nil
    var delay: Double = 0

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(iconColor)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.uppercase)
                    .kerning(0.5)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .scaleEffect(appeared ? 1 : 0.92)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(delay)) {
                appeared = true
            }
        }
    }
}