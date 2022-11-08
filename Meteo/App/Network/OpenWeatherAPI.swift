//
//  OpenWeatherAPI.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import Foundation
import OpenWeather

protocol OpenWeatherAPIWeatherProviding {
  func weatherSummary(for location: Location) async throws -> WeatherSummary
  func forecast(for location: Location) async throws -> WeatherForecast
  func search(_ input: String) async throws -> Set<Location>
}

enum OpenWeatherAPIError: LocalizedError {
  case cannotProvideWeather(location: Location)
  case cannotProvideForecast(location: Location)
}

final actor OpenWeatherAPI: OpenWeatherAPIWeatherProviding {

  static let shared = OpenWeatherAPI()

  /// Open Weather wrapper from open-weather-sdk.
  /// - Note: In a production environment, the authentication token shouldn't be visible here. Alternatives could be storing the secret in the keychain.
  private let openWeather = OpenWeather(token: "4b6d48939ebb16871c7b44244512c341")

  func weatherSummary(for location: Location) async throws -> WeatherSummary {
    let (latitude, longitude) = (location.latitude, location.longitude)
    do {
      let response = try await openWeather.weather(coordinates: .init(latitude: latitude, longitude: longitude))

      return WeatherSummary.make(from: response)
    } catch {
      logger.error("􀁟 \(error.localizedDescription)")
      throw OpenWeatherAPIError.cannotProvideWeather(location: location)
    }
  }

  func forecast(for location: Location) async throws -> WeatherForecast {
    let (latitude, longitude) = (location.latitude, location.longitude)

    do {
      let response = try await openWeather.fiveDayforecast(
        coordinates: .init(latitude: latitude, longitude: longitude))

      return WeatherForecast.make(from: response)
    } catch {
      logger.error("􀁟 \(error.localizedDescription)")
      throw OpenWeatherAPIError.cannotProvideForecast(location: location)
    }
  }

  func search(_ input: String) async throws -> Set<Location> {
    return try await Set(openWeather.directGeocoding(input).map(Location.make(from:)))
  }
}
