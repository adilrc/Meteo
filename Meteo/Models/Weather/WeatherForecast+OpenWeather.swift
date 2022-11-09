//
//  WeatherForecast+OpenWeather.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import Foundation
import OpenWeather

extension WeatherForecast {
    static func make(from response: OWBulkWeatherResponse) -> Self {
        // The reponse provides weather summary every 3 hours for 5 days.
        let summaries = response.list
            .map { WeatherSummary.make(from: $0) }

        logger.info("􀇕 Loaded \(summaries.count) forecasts.")

        return .init(weatherSummaries: summaries)
    }
}

extension WeatherForecast {
    /// Convenience method to only keep on weather summary per day.
    /// This summary is picked up between 10 a.m. and 1 p.m.
    /// - Returns: New forecast with a daily weather summary
    func keepingDailySummary() -> Self {
        let summaries = self.weatherSummaries.filter {
            var calendar = Calendar.current
            calendar.timeZone = $0.timeZone ?? .current

            // 1. Remove today's forecasts
            let isNotToday: Bool = !calendar.isDateInToday($0.date)

            // 2. Use only values between 10 a.m. and 13 p.m.
            // Assuming the API is correct, there should only be one value per day in this range.
            let range = 10..<13
            let isMidDay: Bool = range.contains(calendar.component(.hour, from: $0.date))

            return isNotToday && isMidDay
        }

        return .init(weatherSummaries: summaries)
    }
}
