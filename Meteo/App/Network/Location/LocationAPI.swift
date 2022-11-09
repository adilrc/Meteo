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

    /// Unique task to fetch the user location.
    private var fetchingLocationTask: Task<Location, Error>?

    /// Publisher used to broadcast user locations values from the synchronous delegate call.
    private var currentLocationPublisher: CurrentValueSubject<Result<CLLocation, Error>?, Never> = .init(nil)
    private var locationSubscription: AnyCancellable?

    func userLocation() async throws -> Location {
        logger.info("􀓤 Start fetching user location.")

        // If a task is already in progress, return the value for this task
        if let fetchingLocationTask {
            logger.debug("􀓤 A user location fetch task is pending.")
            return try await fetchingLocationTask.value
        }

        let task = Task {
            // Request user authorization if needed
            locationManager.requestWhenInUseAuthorization()

            guard locationManager.isLocationServiceEnabled else { throw LocationAPIError.userDenied }

            locationManager.anyDelegate = self
            // Hundred meter accuracy is enough as we're only looking for the user city.
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            // Only fetch new location when user is 1km away from the initial location.
            locationManager.distanceFilter = 1000

            // Start listening to user locations updates
            locationManager.startUpdatingLocation()

            let currentLocation = try await withCheckedThrowingContinuation { continuation in
                locationSubscription =
                    currentLocationPublisher
                    .compactMap { $0 }
                    .first()
                    .sink { result in
                        switch result {
                            case let .success(location):
                                continuation.resume(returning: location)
                            case let .failure(error):
                                continuation.resume(throwing: error)
                        }
                    }
            }

            logger.debug("􀓤 User location was found: \(currentLocation.description)")

            // Once the user location acquired, get the current location information.
            let placemarks = try await geocoder.reverseGeocodeLocation(currentLocation)

            guard
                let placemark = placemarks.first,
                let locality = placemark.locality
            else {
                throw LocationAPIError.locationNotFound
            }

            let location = Location(
                locality: locality,
                latitude: currentLocation.coordinate.latitude,
                longitude: currentLocation.coordinate.longitude,
                countryCode: placemark.isoCountryCode,
                state: placemark.region?.identifier)

            logger.debug("􀓤 User location details were found: \(location.description)")

            return location
        }

        self.fetchingLocationTask = task
        defer {
            fetchingLocationTask = nil
            //            currentLocationPublisher.value = nil
        }

        return try await task.value
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
        currentLocationPublisher.value = .success(location)
    }

    func locationManagerDidChangeAuthorization(_ manager: LocationManager) {
        switch manager.authorizationStatus {
            case .denied, .restricted:
                currentLocationPublisher.send(.failure(LocationAPIError.userDenied))
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
