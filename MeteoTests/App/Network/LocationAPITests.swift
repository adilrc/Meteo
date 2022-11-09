//
//  LocationAPITests.swift
//  MeteoTests
//
//  Created by Adil Erchouk on 11/8/22.
//

import XCTest

@testable import Meteo

final class LocationAPITests: XCTestCase {

    let locationManager = LocationManagerMock()
    let geocoder = GeocoderMock()

    private lazy var locationAPI = LocationAPI(locationManager: locationManager, geocoder: geocoder)

    override func tearDown() async throws {
        locationManager._authorizationStatus = .notDetermined
    }

    func testUserDenied() throws {
        Task {
            do {
                _ = try await locationAPI.userLocation()
            } catch {
                XCTAssertEqual(error.localizedDescription, LocationAPIError.userDenied.localizedDescription)
            }
        }

        locationManager._authorizationStatus = .denied
    }

    func testUserAccepted() async throws {
        let locality = "Paris"
        let state = "Ile-de-France"
        let countryCode = "FR"

        // Update the mock geocoder
        geocoder.locality = locality
        geocoder.state = state
        geocoder.countryCode = countryCode

        Task {
            let location = try await locationAPI.userLocation()
            XCTAssertEqual(location.countryCode, locality)
            XCTAssertEqual(location.countryCode, countryCode)
            XCTAssertEqual(location.state, state)
        }

        locationManager._authorizationStatus = .denied
    }
}
