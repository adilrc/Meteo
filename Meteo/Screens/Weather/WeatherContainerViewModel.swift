//
//  WeatherContainerViewModel.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import Combine
import Foundation

protocol WeatherContainerViewModelType: NSObjectProtocol, ObservableObject {
  var selectedLocation: Location? { get }

  var weatherWrapper: WeatherWrapper? { get set }
  var weatherWrapperPublisher: Published<WeatherWrapper?>.Publisher { get }

  func reloadWeatherSummary(
    locAPI: LocationProviding, weatherAPI: OpenWeatherAPIWeatherProviding, force: Bool
  ) async throws -> WeatherWrapper?
  func reloadForecast(
    locAPI: LocationProviding, weatherAPI: OpenWeatherAPIWeatherProviding, force: Bool
  ) async throws -> WeatherForecast?
}

final class WeatherContainerViewModel: NSObject, WeatherContainerViewModelType {
  var selectedLocation: Location?

  init(selectedLocation: Location? = nil) {
    self.selectedLocation = selectedLocation
  }

  private var lastRequestOlderThanFiveMinutes: Bool {
    guard let weatherWrapper else { return true }
    return Date.now.timeIntervalSince(weatherWrapper.weatherSummary.lastUpdate) > 60 * 5
  }

  private func currentLocation(
    _ locAPI: LocationProviding = LocationAPI.shared
  ) async throws
    -> Location
  {
    if let selectedLocation {
      // User has already selected a location
      return selectedLocation
    } else if let userLocation = try await locAPI.userLocation() {
      // No selected locations set yet, use user location.
      return userLocation
    } else {
      // Fallbacks  to a default location if user doesn't provides location
      return .paris
    }
  }

  @MainActor @discardableResult
  func reloadWeatherSummary(
    locAPI: LocationProviding = LocationAPI.shared,
    weatherAPI: OpenWeatherAPIWeatherProviding = OpenWeatherAPI.shared,
    force: Bool = false
  ) async throws -> WeatherWrapper? {
    guard lastRequestOlderThanFiveMinutes || force else { return nil }

    let location = try await currentLocation(locAPI)
    logger.info("􀇕 Reloading weather summary for location: \(location.locality).")
    let weatherSummary = try await weatherAPI.weatherSummary(for: location)

    let wrapper = WeatherWrapper(weatherSummary: weatherSummary, location: location)
    weatherWrapper = wrapper
    return wrapper
  }

  @Published var weatherWrapper: WeatherWrapper?
  var weatherWrapperPublisher: Published<WeatherWrapper?>.Publisher { $weatherWrapper }

  @MainActor @discardableResult
  func reloadForecast(
    locAPI: LocationProviding, weatherAPI: OpenWeatherAPIWeatherProviding, force: Bool
  ) async throws -> WeatherForecast? {
    guard lastRequestOlderThanFiveMinutes || force else { return nil }

    let location = try await currentLocation(locAPI)
    logger.info("􀇕 Reloading weather forecast for location: \(location.locality).")
    let forecast = try await weatherAPI.forecast(for: location)

    return forecast
  }
}
