//
//  SavedCountry.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import Foundation
import SwiftData

@Model
final class SavedCountry {
    var alpha2Code: String
    var name: String
    var capital: String?
    var currencyName: String?
    var currencySymbol: String?
    var currencyCode: String?
    var region: String?
    var population: Int
    var order: Int
    var addedDate: Date

    var flagEmoji: String { alpha2Code.flagEmoji }

    init(from country: Country, order: Int) {
        self.alpha2Code = country.alpha2Code
        self.name = country.name
        self.capital = country.capital
        self.currencyName = country.primaryCurrency?.name
        self.currencySymbol = country.primaryCurrency?.symbol
        self.currencyCode = country.primaryCurrency?.code
        self.region = country.region
        self.population = country.population
        self.order = order
        self.addedDate = Date()
    }

    var currencyDisplay: String {
        let parts = [currencySymbol, currencyCode].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.joined(separator: " · ")
    }
}