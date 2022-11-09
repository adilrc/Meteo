//
//  WeatherSummary.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import Foundation

struct WeatherSummary: Hashable {
    let uuid = UUID()
    let date: Date
    let weatherIconSystemName: String
    let temperature: Measurement<UnitTemperature>

    var minTemp: Measurement<UnitTemperature>?
    var maxTemp: Measurement<UnitTemperature>?
    var description: String?
    var timeZone: TimeZone?

    let lastUpdate: Date
    let isPlaceholder: Bool

    init(
        date: Date,
        weatherIconSystemName: String,
        temperature: Measurement<UnitTemperature>,
        minTemp: Measurement<UnitTemperature>? = nil,
        maxTemp: Measurement<UnitTemperature>? = nil,
        description: String? = nil,
        timeZone: TimeZone? = nil,
        lastUpdate: Date,
        isPlaceholder: Bool
    ) {
        self.date = date
        self.weatherIconSystemName = weatherIconSystemName
        self.temperature = temperature
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.description = description
        self.timeZone = timeZone
        self.lastUpdate = lastUpdate
        self.isPlaceholder = isPlaceholder
    }
}

extension WeatherSummary {
    static var placeholder: Self {
        .init(
            date: .now,
            weatherIconSystemName: "sun.max.fill",
            temperature: .init(value: 20, unit: .celsius),
            timeZone: .init(abbreviation: "GMT"),
            lastUpdate: .now,
            isPlaceholder: true)
    }
}
