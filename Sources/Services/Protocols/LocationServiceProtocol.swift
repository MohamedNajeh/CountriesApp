//
//  LocationServiceProtocol.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import Foundation

protocol LocationServiceProtocol {
    /// Requests the user's current country alpha2 code.
    /// Falls back to "EG" (Egypt) if permission is denied or an error occurs.
    func requestCountryCode() async -> String
}