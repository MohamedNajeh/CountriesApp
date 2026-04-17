//
//  EmptySlotCardView.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import SwiftUI

struct EmptySlotCardView: View {

    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.accentBlue.opacity(0.12))
                        .frame(width: 64, height: 64)

                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.accentBlue)
                }

                Text("Add a Country")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.textSecondary)

                Spacer()
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.cardSurface.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                            )
                            .foregroundStyle(Color.cardBorder)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}