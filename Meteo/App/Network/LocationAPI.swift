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

  private let locationManager = CLLocationManager()
  private var currentLocationPublisher: CurrentValueSubject<CLLocation?, Never> = .init(nil)
  private var subscriptions = Set<AnyCancellable>()

  func userLocation() async throws -> Location {
    locationManager.requestWhenInUseAuthorization()

    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
      // Only fetch new location when
      locationManager.distanceFilter = 1000
      locationManager.startUpdatingLocation()
    }

    let currentLocation = await withCheckedContinuation { continuation in
      currentLocationPublisher
        .compactMap { $0 }
        .first()
        .sink { location in
          continuation.resume(returning: location)
        }
        .store(in: &subscriptions)
    }

    // Get user's current location name
    let geocoder = CLGeocoder()
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

extension LocationAPI: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = manager.location else { return }
    currentLocationPublisher.value = location
  }
}
