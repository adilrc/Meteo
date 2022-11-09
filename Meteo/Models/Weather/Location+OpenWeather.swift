//
//  Location+OpenWeather.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import Foundation
import OpenWeather

extension Location {
    static func make(from response: OWGeocodingResponse) -> Self {
        Location(
            locality: response.name,
            latitude: response.latitude,
            longitude: response.longitude,
            countryCode: response.countryCode,
            state: response.state)
    }
}
