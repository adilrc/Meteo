//
//  FavoriteTileView.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import SwiftUI

struct FavoriteTileView: View {

  private var isCurrentLocation: Bool
  private var locality: String
  private var dateStringAtLocation: String
  private var weatherIconSystemName: String
  private var description: String
  private var temperature: Measurement<UnitTemperature>

  init(
    isCurrentLocation: Bool, locality: String, dateStringAtLocation: String,
    weatherIconSystemName: String, description: String, temperature: Measurement<UnitTemperature>
  ) {
    self.isCurrentLocation = isCurrentLocation
    self.locality = locality
    self.dateStringAtLocation = dateStringAtLocation
    self.weatherIconSystemName = weatherIconSystemName
    self.description = description
    self.temperature = temperature
  }

  private static let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.setLocalizedDateFormatFromTemplate("E")
    return dateFormatter
  }()

  var body: some View {
    GroupBox {
      HStack {
        Image(systemName: weatherIconSystemName)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 60)
          .symbolRenderingMode(.palette)
          .foregroundStyle(
            CustomShapeStyle.primaryStyle(for: weatherIconSystemName),
            CustomShapeStyle.secondaryStyle(for: weatherIconSystemName))
        VStack(alignment: .leading) {
          Text(isCurrentLocation ? "My Location" : locality)
            .lineLimit(1)
            .font(.title2)
          Text(isCurrentLocation ? locality : dateStringAtLocation)
            .lineLimit(1)
            .font(.caption)
            .foregroundColor(.secondary)
        }
        Spacer()
        VStack {
          Text(temperature.formatted(.measurement(width: .narrow, usage: .weather)))
            .font(.largeTitle)
          Text(description)
            .font(.callout)
        }
      }.frame(height: 110)
    }.cornerRadius(30)
  }
}

#if DEBUG
  struct FavoriteTileView_Previews: PreviewProvider {
    static var previews: some View {
      FavoriteTileView(
        isCurrentLocation: true,
        locality: "London",
        dateStringAtLocation: "4:44 AM",
        weatherIconSystemName: "cloud.sun.fill",
        description: "Cloudy",
        temperature: .init(value: 20, unit: .celsius))
    }
  }
#endif
