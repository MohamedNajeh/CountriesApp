//
//  CountryServiceTests.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import XCTest
@testable import CountriesApp

final class CountryServiceTests: XCTestCase {

    private var mockService: MockCountryService!

    override func setUp() {
        super.setUp()
        mockService = MockCountryService()
    }

    override func tearDown() {
        mockService = nil
        super.tearDown()
    }

    // MARK: - fetchAllCountries

    func test_fetchAllCountries_returnsCountries() async throws {
        let expected = [
            MockCountryService.makeCountry(name: "Egypt", alpha2Code: "EG"),
            MockCountryService.makeCountry(name: "France", alpha2Code: "FR")
        ]
        mockService.stubbedCountries = expected

        let result = try await mockService.fetchAllCountries()

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "Egypt")
        XCTAssertEqual(result[1].name, "France")
        XCTAssertEqual(mockService.fetchCallCount, 1)
    }

    func test_fetchAllCountries_throwsNetworkError() async {
        mockService.shouldThrow = NetworkError.invalidURL

        do {
            _ = try await mockService.fetchAllCountries()
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            if case .invalidURL = error {
                // success
            } else {
                XCTFail("Expected invalidURL error")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_fetchAllCountries_returnsEmptyArray() async throws {
        mockService.stubbedCountries = []

        let result = try await mockService.fetchAllCountries()

        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - findCountry(byCode:in:)

    func test_findCountry_byExactCode_returnsCountry() {
        let countries = [
            MockCountryService.makeCountry(name: "Egypt", alpha2Code: "EG"),
            MockCountryService.makeCountry(name: "France", alpha2Code: "FR")
        ]

        let result = mockService.findCountry(byCode: "EG", in: countries)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.name, "Egypt")
    }

    func test_findCountry_caseInsensitive_returnsCountry() {
        let countries = [MockCountryService.makeCountry(name: "Egypt", alpha2Code: "EG")]

        let result = mockService.findCountry(byCode: "eg", in: countries)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.alpha2Code, "EG")
    }

    func test_findCountry_unknownCode_returnsNil() {
        let countries = [MockCountryService.makeCountry(name: "Egypt", alpha2Code: "EG")]

        let result = mockService.findCountry(byCode: "XX", in: countries)

        XCTAssertNil(result)
    }

    func test_findCountry_inEmptyArray_returnsNil() {
        let result = mockService.findCountry(byCode: "EG", in: [])
        XCTAssertNil(result)
    }

    // MARK: - NetworkError descriptions

    func test_networkError_descriptions_areNotEmpty() {
        let errors: [NetworkError] = [
            .invalidURL, .noData, .decodingFailed("decode error"), .requestFailed("request error")
        ]
        for error in errors {
            XCTAssertFalse((error.errorDescription ?? "").isEmpty, "Error description should not be empty for \(error)")
        }
    }
}