//
//  ExtensionsTests.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import XCTest
@testable import CountriesApp

final class ExtensionsTests: XCTestCase {

    // MARK: - String+FlagEmoji

    func test_flagEmoji_egypt_returnsCorrectFlag() {
        XCTAssertEqual("EG".flagEmoji, "🇪🇬")
    }

    func test_flagEmoji_france_returnsCorrectFlag() {
        XCTAssertEqual("FR".flagEmoji, "🇫🇷")
    }

    func test_flagEmoji_usa_returnsCorrectFlag() {
        XCTAssertEqual("US".flagEmoji, "🇺🇸")
    }

    func test_flagEmoji_lowercaseInput_returnsCorrectFlag() {
        XCTAssertEqual("eg".flagEmoji, "🇪🇬")
    }

    func test_flagEmoji_invalidCode_returnsFallback() {
        XCTAssertEqual("X".flagEmoji, "🏳️")
        XCTAssertEqual("".flagEmoji, "🏳️")
        XCTAssertEqual("EGY".flagEmoji, "🏳️")
    }

    // MARK: - Int+Formatted

    func test_formattedPopulation_millions_includesCommas() {
        XCTAssertEqual(1_000_000.formattedPopulation, "1,000,000")
    }

    func test_formattedPopulation_thousands_includesComma() {
        XCTAssertEqual(10_000.formattedPopulation, "10,000")
    }

    func test_formattedPopulation_smallNumber_noComma() {
        XCTAssertEqual(500.formattedPopulation, "500")
    }

    func test_formattedPopulation_zero_returnsZero() {
        XCTAssertEqual(0.formattedPopulation, "0")
    }

    // MARK: - Currency+displayText

    func test_currencyDisplayText_symbolAndCode_joinedWithSeparator() {
        let currency = Currency(code: "EGP", name: "Egyptian Pound", symbol: "£")
        XCTAssertEqual(currency.displayText, "£ · EGP")
    }

    func test_currencyDisplayText_missingSymbol_showsCodeOnly() {
        let currency = Currency(code: "EGP", name: "Egyptian Pound", symbol: nil)
        XCTAssertEqual(currency.displayText, "EGP")
    }

    func test_currencyDisplayText_missingCode_showsSymbolOnly() {
        let currency = Currency(code: nil, name: "Egyptian Pound", symbol: "£")
        XCTAssertEqual(currency.displayText, "£")
    }

    func test_currencyDisplayText_bothNil_returnsEmpty() {
        let currency = Currency(code: nil, name: nil, symbol: nil)
        XCTAssertEqual(currency.displayText, "")
    }

    func test_currencyDisplayText_emptyStrings_returnsEmpty() {
        let currency = Currency(code: "", name: "", symbol: "")
        XCTAssertEqual(currency.displayText, "")
    }
}
