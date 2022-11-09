//
//  LocationAPI.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import Combine
import CoreLocation
import Foundation
import OpenWeather

protocol LocationProviding {
    func userLocation() async throws -> Location
    func isCurrentLocation(_ location: Location) async throws -> Bool
}

enum LocationAPIError: LocalizedError {
    case userDenied
    case locationNotFound
}

final class LocationAPI: NSObject, LocationProviding {
    static let shared = LocationAPI()

    private let locationManager: LocationManager
    private let geocoder: Geocoder

    init(locationManager: LocationManager = CLLocationManager(), geocoder: Geocoder = CLGeocoder()) {
        self.locationManager = locationManager
        self.geocoder = geocoder
    }

    private var currentLocationPublisher: CurrentValueSubject<CLLocation?, Error> = .init(nil)
    private var subscriptions = Set<AnyCancellable>()

    func userLocation() async throws -> Location {
        locationManager.requestWhenInUseAuthorization()

        if locationManager.isLocationServiceEnabled {
            locationManager.anyDelegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            // Only fetch new location when user is 1km away from the initial location.
            locationManager.distanceFilter = 1000
            locationManager.startUpdatingLocation()
        }

        let currentLocation = try await withCheckedThrowingContinuation { continuation in
            currentLocationPublisher
                .compactMap { $0 }
                .first()
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                            case let .failure(error):
                                continuation.resume(throwing: error)
                            default:
                                break
                        }
                    },
                    receiveValue: { location in
                        continuation.resume(returning: location)
                    }
                )
                .store(in: &subscriptions)
        }

        // Get user's current location name
        let placemarks = try await geocoder.reverseGeocodeLocation(currentLocation)

        guard
            let placemark = placemarks.first,
            let locality = placemark.locality
        else { throw LocationAPIError.locationNotFound }

        return Location(
            locality: locality,
            latitude: currentLocation.coordinate.latitude,
            longitude: currentLocation.coordinate.longitude,
            countryCode: placemark.isoCountryCode,
            state: placemark.region?.identifier)
    }

    func isCurrentLocation(_ location: Location) async throws -> Bool {
        // Differente coordinates can be in the same locality, so we are testing for equality using the
        // locality name here.
        try await userLocation().locality == location.locality
    }
}

extension LocationAPI: LocationManagerDelegate {
    func locationManager(_ manager: LocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        currentLocationPublisher.value = location
    }

    func locationManagerDidChangeAuthorization(_ manager: LocationManager) {
        switch manager.authorizationStatus {
            case .denied, .restricted:
                currentLocationPublisher.send(completion: .failure(LocationAPIError.userDenied))
            default:
                break
        }
    }
}

extension LocationAPI: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let manager: LocationManager = manager
        locationManager(manager, didUpdateLocations: locations)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let manager: LocationManager = manager
        locationManagerDidChangeAuthorization(manager)
    }
}
