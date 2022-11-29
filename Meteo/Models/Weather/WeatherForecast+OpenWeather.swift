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
    func keepingDailySummary(from date: Date) -> Self {
        let summaries = self.weatherSummaries.filter {
            var calendar = Calendar.current
            calendar.timeZone = $0.timeZone ?? .current

            // 1. Remove today's forecasts
            let isNotToday: Bool = !calendar.isDate($0.date, inSameDayAs: date)

            // 2. The API doesn't provides 5 summaries but 40 every 3 hours. So the last summary will be at now - 3 hours.
            // To guarantee 5 summaries, we can target now minus 3 hours.
            // Assuming the API is correct, there should only be one value per day in this range.
            let targetHour = calendar.component(.hour, from: date) - 3
            let range = (targetHour - 1) ..< (targetHour + 1)
            let isSameAsTargetHour: Bool = range.contains(calendar.component(.hour, from: $0.date))

            return isNotToday && isSameAsTargetHour
        }

        return .init(weatherSummaries: summaries)
    }
}
