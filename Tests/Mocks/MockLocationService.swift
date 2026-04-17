//
//  MockLocationService.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import Foundation
@testable import CountriesApp

final class MockLocationService: LocationServiceProtocol {

    var stubbedCountryCode: String = "EG"

    func requestCountryCode() async -> String {
        stubbedCountryCode
    }
}