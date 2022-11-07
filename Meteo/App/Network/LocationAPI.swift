//
//  LocationAPI.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import Combine
import CoreLocation
import Foundation
import MapKit

protocol LocationProviding {
  func userLocation() async throws -> Location?
  func search(_ input: String) async throws -> [Location]
  func isCurrentLocation(_ location: Location) async throws -> Bool
}

final class LocationAPI: NSObject, LocationProviding {
  static let shared = LocationAPI()

  private let locationManager = CLLocationManager()
  private var currentLocationPublisher: CurrentValueSubject<CLLocation?, Never> = .init(nil)
  private var subscriptions = Set<AnyCancellable>()

  func userLocation() async throws -> Location? {
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

    guard let locality = placemarks.first?.locality else { return nil }
    
    return .init(
      Location(
        locality: locality,
        latitude: currentLocation.coordinate.latitude,
        longitude: currentLocation.coordinate.longitude))
  }

  private func searchMapItems(_ input: String) async throws -> [MKMapItem] {
    logger.info("􀊫 Starting a search request for '\(input)'...")

    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = input
    let search = MKLocalSearch(request: request)

    return try await search.start().mapItems
  }

  func search(_ input: String) async throws -> [Location] {
    try await searchMapItems(input)
      .compactMap { mapItem -> Location? in
        guard let locality = mapItem.placemark.locality else { return nil }
        return .init(
          locality: locality,
          latitude: mapItem.placemark.coordinate.latitude,
          longitude: mapItem.placemark.coordinate.longitude)

      }
  }

  func isCurrentLocation(_ location: Location) async throws -> Bool {
    // Differente coordinates can be in the same locality, so we are testing for equality using the
    // locality name here.
    try await userLocation()?.locality == location.locality
  }
}

extension LocationAPI: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = manager.location else { return }
    currentLocationPublisher.value = location
  }
}
