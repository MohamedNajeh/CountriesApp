//
//  MockURLProtocol.swift
//  CountriesApp
//
//  Created by MohamedNajeh on 16/04/2026.
//

import Foundation

/// Intercepts URLSession requests and returns stubbed responses — no real network calls.
final class MockURLProtocol: URLProtocol {

    static var stubbedData: Data?
    static var stubbedError: Error?
    static var stubbedStatusCode: Int = 200

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let error = MockURLProtocol.stubbedError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: MockURLProtocol.stubbedStatusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        if let data = MockURLProtocol.stubbedData {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    // MARK: - Helpers

    static func reset() {
        stubbedData = nil
        stubbedError = nil
        stubbedStatusCode = 200
    }

    static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }
}
