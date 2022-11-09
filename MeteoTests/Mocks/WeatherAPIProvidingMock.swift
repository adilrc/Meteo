//
//  WeatherAPIProvidingMock.swift
//  MeteoTests
//
//  Created by Adil Erchouk on 11/8/22.
//

import Foundation

@testable import Meteo

final class WeatherAPIProvidingMock: OpenWeatherAPIWeatherProviding {
    var summary: WeatherSummary?
    var forecast: WeatherForecast?
    var searchLocations: Set<Location>?

    init(summary: WeatherSummary? = nil, forecast: WeatherForecast? = nil, searchLocations: Set<Location>? = nil) {
        self.summary = summary
        self.forecast = forecast
        self.searchLocations = searchLocations
    }

    func weatherSummary(for location: Meteo.Location) async throws -> WeatherSummary {
        summary!
    }

    func forecast(for location: Meteo.Location) async throws -> Meteo.WeatherForecast {
        forecast!
    }

    func search(_ input: String) async throws -> Set<Meteo.Location> {
        searchLocations!
    }
}
