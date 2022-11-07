//
//  WeatherSummaryView.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import SwiftUI

struct WeatherSummaryView: View {
  @ObservedObject var viewModel: WeatherContainerViewModel

  private var summary: WeatherSummary? {
    viewModel.weatherWrapper?.weatherSummary
  }

  var body: some View {
    VStack {
      Spacer()
      WeatherFocusView(
        weatherIconSystemName: summary?.weatherIconSystemName ?? "smoke",
        temperature: summary?.temperature ?? .init(value: 20, unit: .celsius)
      )
      .redacted(reason: viewModel.weatherWrapper != nil ? [] : .placeholder)
      if let lowTemperature = summary?.minTemp, let highTemperature = summary?.maxTemp {
        WeatherLowAndHighView(
          lowTemperature: lowTemperature,
          highTemperature: highTemperature)
      }
      Spacer()
    }
    .task {
      do {
        _ = try await viewModel.reloadWeatherSummary()
      } catch {
        logger.error("\(error.localizedDescription)")
      }
    }
  }
}

#if DEBUG
  struct WeatherSummaryView_Previews: PreviewProvider {
    static var previews: some View {
      WeatherSummaryView(viewModel: .init())
    }
  }
#endif
