//
//  WeatherSummaryTile.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import SwiftUI

struct WeatherSummaryTile: View {

  private var date: Date
  private var weatherIconSystemName: String
  private var temperature: Measurement<UnitTemperature>

  init(date: Date, weatherIconSystemName: String, temperature: Measurement<UnitTemperature>) {
    self.date = date
    self.weatherIconSystemName = weatherIconSystemName
    self.temperature = temperature
  }

  private static let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.setLocalizedDateFormatFromTemplate("E")
    return dateFormatter
  }()

  var body: some View {
    GroupBox {
      VStack {
        HStack {
          Text(Self.dateFormatter.string(from: date))
            .font(.callout)
          Spacer()
        }
        Spacer()
        VStack(alignment: .center) {
          Image(systemName: weatherIconSystemName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 30)
            .symbolRenderingMode(.palette)
            .foregroundStyle(
              CustomShapeStyle.primaryStyle(for: weatherIconSystemName),
              CustomShapeStyle.secondaryStyle(for: weatherIconSystemName))
          Text(temperature.formatted(.measurement(width: .narrow, usage: .weather)))
            .font(.system(size: 28))
            .fontWeight(.bold)
        }
        Spacer()
      }.frame(width: 90, height: 110)
    }.cornerRadius(30)
  }
}

#if DEBUG
  struct WeatherSummaryTile_Previews: PreviewProvider {
    static var previews: some View {
      WeatherSummaryTile(
        date: .now,
        weatherIconSystemName: "cloud.sun.fill",
        temperature: .init(value: 20, unit: .celsius))
    }
  }
#endif
