//
//  WeatherWrapper.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import Foundation

final class WeatherWrapper: NSObject {
  var weatherSummary: WeatherSummary
  let location: Location

  init(weatherSummary: WeatherSummary, location: Location) {
    self.weatherSummary = weatherSummary
    self.location = location
  }
}

extension WeatherWrapper {
  static let parisWeather: WeatherWrapper = .init(weatherSummary: .placeholder, location: .paris)
  static let londonWeather: WeatherWrapper = .init(weatherSummary: .placeholder, location: .london)
  static let sanDiegoWeather: WeatherWrapper = .init(weatherSummary: .placeholder, location: .sanDiego)
}
