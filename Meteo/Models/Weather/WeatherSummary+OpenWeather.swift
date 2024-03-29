//
//  WeatherSummary+OpenWeather.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import Foundation
import OpenWeather

extension WeatherSummary {
    static let placeholderSystemName = "thermometer.medium.slash"

    static func make(from response: OWSimpleWeatherResponse) -> Self {
        return .init(
            date: response.date,
            weatherIconSystemName: response.summaries.first?.weatherIconSystemName
                ?? placeholderSystemName,
            temperature: .init(
                value: response.mainMetrics.temperature.rounded(),
                unit: .celsius),
            minTemp: response.mainMetrics.tempMin.flatMap { .init(value: $0.rounded(), unit: .celsius) },
            maxTemp: response.mainMetrics.tempMax.flatMap { .init(value: $0.rounded(), unit: .celsius) },
            description: response.summaries.first?.description,
            timeZone: response.timeZone,
            lastUpdate: response.date,
            isPlaceholder: false)
    }
}
