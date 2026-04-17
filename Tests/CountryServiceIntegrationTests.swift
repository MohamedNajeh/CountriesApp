//
//  CountryServiceIntegrationTests.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import XCTest
@testable import CountriesApp

final class CountryServiceIntegrationTests: XCTestCase {

    private var service: CountryService!

    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
        service = CountryService(session: MockURLProtocol.makeSession())
    }

    override func tearDown() {
        service = nil
        MockURLProtocol.reset()
        super.tearDown()
    }

    // MARK: - fetchAllCountries

    func test_fetchAllCountries_validJSON_returnsCountries() async throws {
        MockURLProtocol.stubbedData = validCountriesJSON()

        let countries = try await service.fetchAllCountries()

        XCTAssertEqual(countries.count, 2)
        XCTAssertEqual(countries[0].name, "Egypt")
        XCTAssertEqual(countries[0].alpha2Code, "EG")
        XCTAssertEqual(countries[0].capital, "Cairo")
        XCTAssertEqual(countries[0].primaryCurrency?.code, "EGP")
        XCTAssertEqual(countries[0].region, "Africa")
        XCTAssertEqual(countries[0].population, 102_334_403)
    }

    func test_fetchAllCountries_validJSON_returnsFlagEmoji() async throws {
        MockURLProtocol.stubbedData = validCountriesJSON()

        let countries = try await service.fetchAllCountries()

        XCTAssertEqual(countries[0].flagEmoji, "🇪🇬")
        XCTAssertEqual(countries[1].flagEmoji, "🇫🇷")
    }

    func test_fetchAllCountries_emptyArray_returnsEmpty() async throws {
        MockURLProtocol.stubbedData = Data("[]".utf8)

        let countries = try await service.fetchAllCountries()

        XCTAssertTrue(countries.isEmpty)
    }

    func test_fetchAllCountries_invalidJSON_throwsDecodingFailed() async {
        MockURLProtocol.stubbedData = Data("{\"error\":\"bad\"}".utf8)

        do {
            _ = try await service.fetchAllCountries()
            XCTFail("Expected decodingFailed error")
        } catch let error as NetworkError {
            if case .decodingFailed = error { /* pass */ }
            else { XCTFail("Expected decodingFailed, got \(error)") }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_fetchAllCountries_networkError_throwsRequestFailed() async {
        MockURLProtocol.stubbedError = URLError(.notConnectedToInternet)

        do {
            _ = try await service.fetchAllCountries()
            XCTFail("Expected requestFailed error")
        } catch let error as NetworkError {
            if case .requestFailed = error { /* pass */ }
            else { XCTFail("Expected requestFailed, got \(error)") }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_fetchAllCountries_cachesOnSecondCall() async throws {
        MockURLProtocol.stubbedData = validCountriesJSON()

        let first = try await service.fetchAllCountries()
        // Clear stub — second call should use cache, not network
        MockURLProtocol.stubbedData = nil
        MockURLProtocol.stubbedError = URLError(.notConnectedToInternet)
        let second = try await service.fetchAllCountries()

        XCTAssertEqual(first.count, second.count)
    }

    // MARK: - findCountry

    func test_findCountry_byCode_returnsMatch() async throws {
        MockURLProtocol.stubbedData = validCountriesJSON()
        let countries = try await service.fetchAllCountries()

        let result = service.findCountry(byCode: "EG", in: countries)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "Egypt")
    }

    func test_findCountry_unknownCode_returnsNil() async throws {
        MockURLProtocol.stubbedData = validCountriesJSON()
        let countries = try await service.fetchAllCountries()

        let result = service.findCountry(byCode: "XX", in: countries)

        XCTAssertNil(result)
    }

    // MARK: - Stubbed JSON

    private func validCountriesJSON() -> Data {
        let json = """
        [
            {
                "name": { "common": "Egypt" },
                "cca2": "EG",
                "capital": ["Cairo"],
                "currencies": { "EGP": { "name": "Egyptian Pound", "symbol": "£" } },
                "region": "Africa",
                "population": 102334403
            },
            {
                "name": { "common": "France" },
                "cca2": "FR",
                "capital": ["Paris"],
                "currencies": { "EUR": { "name": "Euro", "symbol": "€" } },
                "region": "Europe",
                "population": 67391582
            }
        ]
        """
        return Data(json.utf8)
    }
}
