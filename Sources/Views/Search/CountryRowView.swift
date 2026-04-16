//
//  CountryRowView.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import SwiftUI

struct CountryRowView: View {

    let country: Country
    let isAdded: Bool

    var body: some View {
        HStack(spacing: 14) {
            Text(country.flagEmoji)
                .font(.system(size: 36))
                .frame(width: 48, height: 48)
                .background(Color.cardBorder.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(country.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(isAdded ? Color.textSecondary : .white)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if let capital = country.capital, !capital.isEmpty {
                        Label(capital, systemImage: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                    }
                    if let code = country.primaryCurrency?.code {
                        Text("· \(code)")
                            .font(.caption)
                            .foregroundStyle(Color.accentBlue.opacity(0.8))
                    }
                }
            }

            Spacer()

            if isAdded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.successGreen)
                    .font(.title3)
            }
        }
        .padding(.vertical, 6)
        .opacity(isAdded ? 0.55 : 1)
    }
}