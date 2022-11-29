//
//  WeatherContainerViewModelTests.swift
//  MeteoTests
//
//  Created by Adil Erchouk on 11/8/22.
//

import OpenWeather
import XCTest

@testable import Meteo

final class WeatherContainerViewModelTests: XCTestCase {
    let locationAPI = LocationAPIMock(userLocation: .paris)
    let weatherAPI = WeatherAPIProvidingMock()

    private var viewModel: WeatherContainerViewModel!

    func testReloadWeatherSummaryWithUserLocation() async throws {
        viewModel = WeatherContainerViewModel(locationAPI: locationAPI, weatherAPI: weatherAPI)
        weatherAPI.summary = .placeholder
        let wrapper = try await viewModel.reloadWeatherSummary()

        XCTAssertEqual(wrapper?.location, locationAPI.userLocation)
        XCTAssertEqual(wrapper?.weatherSummary, weatherAPI.summary)
    }

    func testReloadWeatherSummaryWithSelectedLocation() async throws {
        viewModel = WeatherContainerViewModel(selectedLocation: .london, locationAPI: locationAPI, weatherAPI: weatherAPI)
        weatherAPI.summary = .placeholder

        let wrapper = try await viewModel.reloadWeatherSummary()

        XCTAssertEqual(wrapper?.location, .london)
        XCTAssertEqual(wrapper?.weatherSummary, weatherAPI.summary)
    }

    func testReloadForecast() async throws {
        viewModel = WeatherContainerViewModel(selectedLocation: .london, locationAPI: locationAPI, weatherAPI: weatherAPI)
        let response = WeatherForecast.make(from: OWResponsesMock.bulkWeatherResponseLondonObject)
        weatherAPI.forecast = .init(weatherSummaries: response.weatherSummaries)

        let forecast = try await viewModel.reloadForecast(force: false, from: response.weatherSummaries.first?.date ?? .now)

        // Only 5 summaries should remains (5 days forecast)
        XCTAssertEqual(forecast?.weatherSummaries.count, 4)

        // All of the forecast should be in differente days
        let dates = forecast?.weatherSummaries.map(\.date) ?? []
        XCTAssertEqual(Set(dates).count, 4)
    }
}
