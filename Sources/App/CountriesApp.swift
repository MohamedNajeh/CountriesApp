//
//  CountriesApp.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import SwiftUI
import SwiftData

@main
struct CountriesApp: App {

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: SavedCountry.self)
    }
}