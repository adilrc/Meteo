//
//  LocationManager.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/8/22.
//

import CoreLocation
import Foundation

/// `CLLocationManager` abstraction to allow  mocking.
protocol LocationManager: AnyObject {

    var anyDelegate: LocationManagerDelegate? { get set }
    var isLocationServiceEnabled: Bool { get }

    // CLLocationManager Properties
    var location: CLLocation? { get }
    var desiredAccuracy: CLLocationAccuracy { get set }
    var distanceFilter: CLLocationDistance { get set }
    var authorizationStatus: CLAuthorizationStatus { get }

    // CLLocationManager Methods
    func startUpdatingLocation()
    func requestWhenInUseAuthorization()
}

/// `CLLocationManagerDelegate` abstraction to allow mocking.
protocol LocationManagerDelegate {
    func locationManager(_ manager: LocationManager, didUpdateLocations locations: [CLLocation])
    func locationManagerDidChangeAuthorization(_ manager: LocationManager)
}

extension CLLocationManager: LocationManager {
    var isLocationServiceEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }

    var anyDelegate: LocationManagerDelegate? {
        get {
            delegate as? LocationManagerDelegate
        }
        set {
            delegate = newValue as? CLLocationManagerDelegate
        }
    }
}
