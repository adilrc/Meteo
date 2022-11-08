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
  private var isPlaceholder: Bool

  init(
    isCurrentLocation: Bool, locality: String, dateStringAtLocation: String, weatherIconSystemName: String, description: String,
    temperature: Measurement<UnitTemperature>, isPlaceholder: Bool
  ) {
    self.isCurrentLocation = isCurrentLocation
    self.locality = locality
    self.dateStringAtLocation = dateStringAtLocation
    self.weatherIconSystemName = weatherIconSystemName
    self.description = description
    self.temperature = temperature
    self.isPlaceholder = isPlaceholder
  }

  private static let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.setLocalizedDateFormatFromTemplate("E")
    return dateFormatter
  }()

  var body: some View {
    GroupBox {
      HStack(spacing: 20) {
        Image(systemName: weatherIconSystemName)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 50)
          .symbolRenderingMode(.palette)
          .foregroundStyle(
            CustomShapeStyle.primaryStyle(for: weatherIconSystemName),
            CustomShapeStyle.secondaryStyle(for: weatherIconSystemName))
        VStack(alignment: .leading) {
          Text(isCurrentLocation ? "My Location" : locality)
            .lineLimit(1)
            .font(.title2)
          Text(isCurrentLocation ? locality : dateStringAtLocation)
            .lineLimit(2)
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .layoutPriority(1)
        Spacer()
        VStack(alignment: .trailing) {
          Text(temperature.formatted(.measurement(width: .narrow, usage: .weather)))
            .font(.largeTitle)
          Text(description)
            .font(.caption)
            .lineLimit(2)
            .frame(maxWidth: 60)
        }
      }.frame(height: 80)
    }
    .cornerRadius(20)
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
        description: "overcastsclouds",
        temperature: .init(value: 20, unit: .celsius),
        isPlaceholder: false
      ).frame(width: 350)
    }
  }
#endif
