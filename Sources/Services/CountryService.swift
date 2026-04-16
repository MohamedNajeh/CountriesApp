//
//  CountryService.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(String)
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:               return "Invalid API URL."
        case .noData:                   return "No data received from the server."
        case .decodingFailed(let msg):  return "Failed to parse server response: \(msg)"
        case .requestFailed(let msg):   return msg
        }
    }
}

final class CountryService: CountryServiceProtocol {

    // v3.1 with only the fields we need (v2 is deprecated)
    private let apiURL = "https://restcountries.com/v3.1/all?fields=name,cca2,capital,currencies,region,population"
    private let session: URLSession

    /// In-memory cache to avoid redundant network calls within the same session.
    private var cachedCountries: [Country]?

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchAllCountries() async throws -> [Country] {
        if let cached = cachedCountries {
            return cached
        }

        guard let url = URL(string: apiURL) else {
            throw NetworkError.invalidURL
        }

        let data: Data
        do {
            let (responseData, _) = try await session.data(from: url)
            data = responseData
        } catch {
            throw NetworkError.requestFailed(error.localizedDescription)
        }

        guard !data.isEmpty else {
            throw NetworkError.noData
        }

        do {
            let responses = try JSONDecoder().decode([CountryAPIResponse].self, from: data)
            let countries = responses.map { $0.toDomain() }
            cachedCountries = countries
            return countries
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }

    func findCountry(byCode alpha2Code: String, in countries: [Country]) -> Country? {
        countries.first { $0.alpha2Code.uppercased() == alpha2Code.uppercased() }
    }
}