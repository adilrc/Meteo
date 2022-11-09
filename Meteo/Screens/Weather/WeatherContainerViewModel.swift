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

    private(set) var selectedLocation: Location?
    private var subscriptions = Set<AnyCancellable>()

    private func setupListeners() {
        NotificationCenter.default.publisher(for: .userDidSelectLocation)
            .compactMap { $0.userInfo?[UserSelectedLocation.key] as? WeatherWrapper }
            .sink { [weak self] weatherWrapper in
                guard let self = self else { return }
                self.selectedLocation = weatherWrapper.location
                self.weatherWrapper = weatherWrapper
            }
            .store(in: &subscriptions)
    }

    init(selectedLocation: Location? = nil) {
        self.selectedLocation = selectedLocation
        super.init()
        setupListeners()
    }

    private var lastRequestOlderThanTenMinutes: Bool {
        guard let weatherWrapper else { return true }
        return Date.now.timeIntervalSince(weatherWrapper.weatherSummary.lastUpdate) > 60 * 10
    }

    private func currentLocation(
        _ locAPI: LocationProviding = LocationAPI.shared
    ) async throws
        -> Location
    {
        if let selectedLocation {
            // User has already selected a location
            return selectedLocation
        } else if var userLocation = try? await locAPI.userLocation() {
            // No selected locations set yet, use user location.
            userLocation.setAsCurrentLocation()
            return userLocation
        } else {
            // Fallbacks  to a default location if user doesn't provides location
            return .sanDiego
        }
    }

    @MainActor @discardableResult
    func reloadWeatherSummary(
        locAPI: LocationProviding = LocationAPI.shared,
        weatherAPI: OpenWeatherAPIWeatherProviding = OpenWeatherAPI.shared,
        force: Bool = false
    ) async throws -> WeatherWrapper? {
        guard lastRequestOlderThanTenMinutes || force else { return nil }

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
        guard lastRequestOlderThanTenMinutes || force else { return nil }

        let location = try await currentLocation(locAPI)
        logger.info("􀇕 Reloading weather forecast for location: \(location.locality).")
        let forecast = try await weatherAPI.forecast(for: location).keepingDailySummary()

        return forecast
    }
}
