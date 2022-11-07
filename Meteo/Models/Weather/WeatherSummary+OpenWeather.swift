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
    let temperatureUnit = UnitTemperature(forLocale: .autoupdatingCurrent)

    return .init(
      date: response.date,
      weatherIconSystemName: (try? response.summaries.first?.weatherIconSystemName)
        ?? placeholderSystemName,
      temperature: .init(
        value: response.mainMetrics.temperature,
        unit: temperatureUnit),
      minTemp: response.mainMetrics.tempMin.flatMap { .init(value: $0, unit: temperatureUnit) },
      maxTemp: response.mainMetrics.tempMax.flatMap { .init(value: $0, unit: temperatureUnit) },
      lastUpdate: response.date,
      isPlaceholder: false)
  }
}
