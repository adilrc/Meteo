//
//  SearchContainerViewModel.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import Combine
import Foundation

protocol SearchContainerViewModelType {
    func reloadFavoriteLocations() async throws -> [Location]
    func refresh(_ weatherWrappers: [WeatherWrapper], force: Bool, priority: TaskPriority) async throws -> [Result<WeatherWrapper, Error>]?

    func addFavorite(_ location: Location)
    func removeFavorite(_ location: Location)

    static func timeLabel(for weatherSummary: WeatherSummary) -> String
}

final class SearchContainerViewModel: SearchContainerViewModelType {

    private let userDefaults: UserDefaults
    private let locationAPI: LocationProviding
    private let weatherAPI: OpenWeatherAPIWeatherProviding

    init(userDefaults: UserDefaults = UserDefaults.standard,
         locationAPI: LocationProviding = LocationAPI.shared,
         weatherAPI: OpenWeatherAPIWeatherProviding = OpenWeatherAPI.shared) {
        self.userDefaults = userDefaults
        self.locationAPI = locationAPI
        self.weatherAPI = weatherAPI
    }

    func reloadFavoriteLocations() async throws -> [Location] {
        var locations: [Location] = []

        let favoriteLocations = FavoritesStore.favorites(userDefault: userDefaults)?.locations ?? []

        // 1. First favorite is the user location if user accepted to provide location data.
        do {
            var location = try await locationAPI.userLocation()
            location.setAsCurrentLocation()
            locations.append(location)
        } catch LocationAPIError.userDenied {
            // User has refused to give location, don't add the user location
        } catch {
            throw error
        }

        // 2. The rest of the favorites are the actual user defined favs
        // If no favorites (e.g. first setup) add a default set of favorites and add them to the store.
        if locations.isEmpty {
            let defaultFavorites: [Location] = [.sanDiego, .london, .paris]
            FavoritesStore.store(.init(locations: defaultFavorites))
            locations.append(contentsOf: defaultFavorites)
        } else {
            locations.append(contentsOf: favoriteLocations)
        }

        return locations
    }

    func refresh(_ weatherWrappers: [WeatherWrapper], force: Bool, priority: TaskPriority) async -> [Result<WeatherWrapper, Error>]? {
        guard let firstWrapper = weatherWrappers.first else { return nil }

        if let newLocation = try? await locationAPI.userLocation(), newLocation != firstWrapper.location {
            // If the location changed replace the location of the first wrapper
            firstWrapper.location = newLocation
        }

        var isFirstRequest: Bool { firstWrapper.weatherSummary.isPlaceholder }
        var lastRequestOlderThanTenMinutes: Bool { Date.now.timeIntervalSince(firstWrapper.weatherSummary.lastUpdate) > 60 * 10 }

        guard isFirstRequest || lastRequestOlderThanTenMinutes || force else { return nil }

        return await withTaskGroup(of: Result<WeatherWrapper, Error>.self) { [unowned self] taskGroup in
            var results = [Result<WeatherWrapper, Error>]()

            for wrapper in weatherWrappers {
                taskGroup.addTask(priority: priority) {
                    do {
                        let summary = try await self.weatherAPI.weatherSummary(for: wrapper.location)
                        wrapper.weatherSummary = summary
                        return .success(wrapper)
                    } catch {
                        return .failure(error)
                    }
                }
            }

            for await result in taskGroup {
                results.append(result)
            }

            return results
        }
    }

    static func timeLabel(for weatherSummary: WeatherSummary) -> String {
        guard let locationTimeZone = weatherSummary.timeZone else { return "" }
        logger.debug("􀐫 Getting time label in time zone \(locationTimeZone.description) for date: \(weatherSummary.date.description)")
        var formatStyle: Date.FormatStyle = .dateTime
        formatStyle.timeZone = locationTimeZone
        // Use `11:30 PM` format, localized aware so it can appear as `23:30`
        let output = weatherSummary.date.formatted(formatStyle.hour(.conversationalDefaultDigits(amPM: .wide)).minute())
        logger.debug("􀐫 Time label: \(output)")
        return output
    }

    func addFavorite(_ location: Location) {
        let currentFavorites = FavoritesStore.favorites()?.locations ?? []
        logger.info("􀋃 Adding \(location.description) to user favorites.")

        FavoritesStore.store(.init(locations: currentFavorites + [location]))
    }

    func removeFavorite(_ location: Location) {
        guard let currentFavorites = FavoritesStore.favorites()?.locations else { return }
        logger.info("􀋃 Removing \(location.description) from user favorites.")

        let filteredFavorites = currentFavorites.filter { $0 != location }
        FavoritesStore.store(.init(locations: filteredFavorites))
    }
}
