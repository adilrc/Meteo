//
//  Geocoder.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/8/22.
//

import CoreLocation
import Foundation

/// `CLGeocoder` abstraction to allow mocking
protocol Geocoder {
    func reverseGeocodeLocation(_ location: CLLocation) async throws -> [CLPlacemark]
}

extension CLGeocoder: Geocoder {}
