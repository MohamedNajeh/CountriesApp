//
//  CountryServiceProtocol.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import Foundation

protocol CountryServiceProtocol {
    func fetchAllCountries() async throws -> [Country]
    func findCountry(byCode alpha2Code: String, in countries: [Country]) -> Country?
}