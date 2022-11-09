//
//  OpenWeatherAPIsProviderMock.swift
//  MeteoTests
//
//  Created by Adil Erchouk on 11/8/22.
//

import Foundation
import OpenWeather

@testable import Meteo

actor OpenWeatherAPIsProviderMock: OpenWeatherAPIsProvider {
    var weatherResponse: Result<OWSimpleWeatherResponse, Error>?
    var fiveDayForecastResponse: Result<OWBulkWeatherResponse, Error>?
    var geocodingResponses: Result<[OWGeocodingResponse], Error>?

    func setWeatherResponse(_ response: Result<OWSimpleWeatherResponse, Error>?) {
        weatherResponse = response
    }

    func setForecastResponse(_ response: Result<OWBulkWeatherResponse, Error>?) {
        fiveDayForecastResponse = response
    }

    func setGeocodingResponse(_ response: Result<[OWGeocodingResponse], Error>?) {
        geocodingResponses = response
    }

    func weather(coordinates: OWCoordinates) async throws -> OWSimpleWeatherResponse {
        try weatherResponse?.get() ?? { fatalError() }()
    }

    func fiveDayforecast(coordinates: OWCoordinates) async throws -> OWBulkWeatherResponse {
        try fiveDayForecastResponse?.get() ?? { fatalError() }()
    }

    func directGeocoding(_ locationName: String) async throws -> [OWGeocodingResponse] {
        try geocodingResponses?.get() ?? { fatalError() }()
    }
}
