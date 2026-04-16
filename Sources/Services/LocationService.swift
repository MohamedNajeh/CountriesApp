//
//  LocationService.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import Foundation
import CoreLocation

final class LocationService: NSObject, CLLocationManagerDelegate, LocationServiceProtocol {

    private let defaultCountryCode = "EG"
    private let timeoutInterval: TimeInterval = 8

    private var manager: CLLocationManager?
    private var continuation: CheckedContinuation<String, Never>?
    private var isResumed = false

    func requestCountryCode() async -> String {
        return await withCheckedContinuation { cont in
            // CLLocationManager must be created and used on the main thread
            DispatchQueue.main.async {
                self.isResumed = false
                self.continuation = cont

                let mgr = CLLocationManager()
                mgr.delegate = self
                self.manager = mgr

                switch mgr.authorizationStatus {
                case .authorizedWhenInUse, .authorizedAlways:
                    mgr.requestLocation()
                case .notDetermined:
                    mgr.requestWhenInUseAuthorization()
                default:
                    self.resumeOnce(with: self.defaultCountryCode)
                }

                // Safety timeout — always resumes the continuation even if CLLocationManager stalls
                DispatchQueue.main.asyncAfter(deadline: .now() + self.timeoutInterval) { [weak self] in
                    self?.resumeOnce(with: self?.defaultCountryCode ?? "EG")
                }
            }
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            resumeOnce(with: defaultCountryCode)
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            resumeOnce(with: defaultCountryCode)
            return
        }
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self else { return }
            let code = placemarks?.first?.isoCountryCode ?? self.defaultCountryCode
            DispatchQueue.main.async { self.resumeOnce(with: code) }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resumeOnce(with: defaultCountryCode)
    }

    // MARK: - Private

    private func resumeOnce(with code: String) {
        guard !isResumed else { return }
        isResumed = true
        continuation?.resume(returning: code)
        continuation = nil
        manager?.delegate = nil
        manager = nil
    }
}