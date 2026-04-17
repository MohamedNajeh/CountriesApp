//
//  AnimatedGradientBackground.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import SwiftUI

struct AnimatedGradientBackground: View {

    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "#0A0E1A"),
                Color(hex: "#111428"),
                Color(hex: "#0D1230"),
                Color(hex: "#0A0E1A")
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}