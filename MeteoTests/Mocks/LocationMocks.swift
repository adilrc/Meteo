//
//  LocationManagerMock.swift
//  MeteoTests
//
//  Created by Adil Erchouk on 11/8/22.
//

import CoreLocation
import Foundation
import MapKit

@testable import Meteo

final class LocationManagerMock: LocationManager {

    let isLocationServiceEnabled: Bool = true
    var location: CLLocation?
    var anyDelegate: LocationManagerDelegate?
    var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters
    var distanceFilter: CLLocationDistance = 1000
    var _authorizationStatus: CLAuthorizationStatus = .notDetermined
    var authorizationStatus: CLAuthorizationStatus { _authorizationStatus }

    func startUpdatingLocation() {
        anyDelegate?.locationManager(self, didUpdateLocations: [.init(latitude: 0, longitude: 0)])
    }

    func requestWhenInUseAuthorization() {
        anyDelegate?.locationManagerDidChangeAuthorization(self)
    }
}

final class GeocoderMock: Geocoder {
    var locality: String = ""
    var countryCode: String = ""
    var state: String = ""

    func reverseGeocodeLocation(_ location: CLLocation) async throws -> [CLPlacemark] {
        [CLPlacemark(placemark: CLPlacemarkMock(locality: locality, countryCode: countryCode, state: state))]
    }
}

// Cannot subclass CLPlacemark directly to mock it, so subclassing MKPlacemark instead.
final class CLPlacemarkMock: MKPlacemark {

    convenience init(locality: String, countryCode: String, state: String) {
        self.init(
            coordinate: .init(),
            addressDictionary: [
                "Locality": locality,
                "Country": countryCode,
                "State": state,
            ])
    }
}

final class LocationAPIMock: LocationProviding {
    var userLocation: Location?

    init(userLocation: Location?) {
        self.userLocation = userLocation
    }

    func userLocation() async throws -> Location {
        return try userLocation ?? { throw LocationAPIError.userDenied }()
    }

    func isCurrentLocation(_ location: Location) async throws -> Bool {
        return location == userLocation
    }
}
