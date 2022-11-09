//
//  OpenWeatherAPITests.swift
//  MeteoTests
//
//  Created by Adil Erchouk on 11/8/22.
//

import OpenWeather
import XCTest

@testable import Meteo

final class OpenWeatherAPITests: XCTestCase {
    private let mockAPIsProvider = OpenWeatherAPIsProviderMock()
    private lazy var openWeather = OpenWeatherAPI(openWeather: mockAPIsProvider)

    override func tearDown() async throws {
        await mockAPIsProvider.setWeatherResponse(nil)
        await mockAPIsProvider.setForecastResponse(nil)
        await mockAPIsProvider.setGeocodingResponse(nil)
    }

    private func testMapping(between response: OWSimpleWeatherResponse, and summary: WeatherSummary) {
        XCTAssertEqual(summary.weatherIconSystemName, response.summaries.first?.weatherIconSystemName)
        XCTAssertEqual(summary.lastUpdate, response.date)
        XCTAssertEqual(summary.description, response.summaries.first?.description)
        XCTAssertEqual(summary.maxTemp?.value, response.mainMetrics.tempMax)
        XCTAssertEqual(summary.minTemp?.value, response.mainMetrics.tempMin)
        XCTAssertEqual(summary.temperature.value, response.mainMetrics.temperature)
        XCTAssertEqual(summary.timeZone, response.timeZone)
    }

    func testWeatherResponse() async throws {
        let mock = OWResponsesMock.simpleWeatherResponseLondonObject
        await mockAPIsProvider.setWeatherResponse(.success(mock))

        let summary = try await openWeather.weatherSummary(for: .london)

        testMapping(between: mock, and: summary)
    }

    func testForecastResponse() async throws {
        let mock = OWResponsesMock.bulkWeatherResponseLondonObject

        await mockAPIsProvider.setForecastResponse(.success(mock))

        let forecast = try await openWeather.forecast(for: .london)

        XCTAssertEqual(mock.list.count, forecast.weatherSummaries.count)
        for (response, summary) in zip(mock.list, forecast.weatherSummaries) {
            testMapping(between: response, and: summary)
        }
    }

    func testLocationSearch() async throws {
        // The API returns duplicated locations, this should be fitered
        // In this case there's 2 duplicates
        let mock = OWResponsesMock.directGeocodingResponseParisObject
        let duplicatesCount: Int = 2

        await mockAPIsProvider.setGeocodingResponse(.success(mock))

        let locations = try await openWeather.search("")

        // Duplicates are filtered out
        XCTAssertEqual(mock.count - duplicatesCount, locations.count)

        for response in mock {
            XCTAssertTrue(locations.contains(where: { $0.countryCode == response.countryCode }))
            XCTAssertTrue(locations.contains(where: { $0.locality == response.name }))
            XCTAssertTrue(locations.contains(where: { $0.state == response.state }))
            // Just test double with one digits after 0
            XCTAssertTrue(locations.contains(where: { String(format: "%.1f", $0.longitude) == String(format: "%.1f", response.longitude) }))
            XCTAssertTrue(locations.contains(where: { String(format: "%.1f", $0.latitude) == String(format: "%.1f", response.latitude) }))
        }
    }
}
