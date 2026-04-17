//
//  CountryCardView.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import SwiftUI

struct CountryCardView: View {

    let country: SavedCountry
    let onRemove: () -> Void

    @State private var appeared = false
    @State private var showDeleteConfirm = false

    var body: some View {
        HStack(spacing: 16) {
            // Flag
            Text(country.flagEmoji)
                .font(.system(size: 52))
                .frame(width: 64, height: 64)
                .background(Color.cardBorder.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            // Info
            VStack(alignment: .leading, spacing: 5) {
                Text(country.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                if let capital = country.capital, !capital.isEmpty {
                    Label(capital, systemImage: "mappin.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                }

                if !country.currencyDisplay.isEmpty {
                    Label(country.currencyDisplay, systemImage: "banknote")
                        .font(.caption)
                        .foregroundStyle(Color.accentBlue)
                }
            }

            Spacer()

            // Delete button
            Button {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .padding(8)
                    .background(Color.cardBorder.opacity(0.6))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.accentBlue.opacity(0.4), Color.accentPurple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.accentBlue.opacity(0.08), radius: 12, x: 0, y: 4)
        .scaleEffect(appeared ? 1 : 0.94)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                appeared = true
            }
        }
        .confirmationDialog(
            "Remove \(country.name)?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) { onRemove() }
            Button("Cancel", role: .cancel) { }
        }
    }
}