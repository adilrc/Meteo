//
//  SearchContainerViewModelTests.swift
//  MeteoTests
//
//  Created by Adil Erchouk on 11/8/22.
//

import XCTest
@testable import Meteo

final class SearchContainerViewModelTests: XCTestCase {
    var locationAPI = LocationAPIMock(userLocation: nil)
    let weatherAPI = WeatherAPIProvidingMock()
    var userDefaults = UserDefaults(suiteName: #file)!
    
    private var viewModel: SearchContainerViewModel!
    
    override func tearDown() {
        locationAPI.userLocation = nil
        userDefaults.removePersistentDomain(forName: #file)
    }

    override func setUp() {
        userDefaults.removePersistentDomain(forName: #file)
    }
    
    func testReloadFavoriteLocationsEmptyAndNoUserLocation() async throws {
        viewModel = .init(userDefaults: userDefaults,
                         locationAPI: locationAPI,
                         weatherAPI: weatherAPI)
        locationAPI.userLocation = nil
        
        let locations = try await viewModel.reloadFavoriteLocations()
        
        // Fallbacks to default favorites
        XCTAssertEqual(locations, [.sanDiego, .london, .paris])
    }
    
    func testReloadFavoriteLocationsEmptyAndUserLocation() async throws {
        viewModel = .init(userDefaults: userDefaults,
                         locationAPI: locationAPI,
                         weatherAPI: weatherAPI)
        locationAPI.userLocation = .london
        
        let locations = try await viewModel.reloadFavoriteLocations()
        
        // Return user location
        XCTAssertEqual(locations, [.london])
    }
    
    func testReloadFavoriteLocationsNotEmptyAndUserLocation() async throws {
        viewModel = .init(userDefaults: userDefaults,
                         locationAPI: locationAPI,
                         weatherAPI: weatherAPI)
        FavoritesStore.store(.init(locations: [.sanDiego, .paris]), userDefault: userDefaults)
        locationAPI.userLocation = .london
        
        let locations = try await viewModel.reloadFavoriteLocations()
        
        // Returns user location + favorites
        XCTAssertEqual(locations, [.london, .sanDiego, .paris])
    }
    
    func testTimeLabel() {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")

        // User time zone is GMT (10:00 a.m.)
        let date = dateFormatter.date(from: "2022-08-19T10:00:00-00:00")!
        
        // The weather's location is in PST time zone, so 3:00 a.m. (-8 hours) is the expected output.
        let weatherLocationTimeZone = TimeZone(identifier: "PST")
        let weatherSummary = WeatherSummary(date: date,
                                            weatherIconSystemName: "",
                                            temperature: .init(value: 20, unit: .celsius),
                                            timeZone: weatherLocationTimeZone,
                                            lastUpdate: .now,
                                            isPlaceholder: true)
        
        let label = SearchContainerViewModel.timeLabel(for: weatherSummary)
        
        let expectedTime = weatherLocationTimeZone?.isDaylightSavingTime(for: .now) == true ? "2:00 AM" : "3:00 AM"
        XCTAssertEqual(label, expectedTime)
    }
}
