//
//  WeatherLowAndHighView.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import SwiftUI

/// View representing the current weather's min and max temperatures.
struct WeatherLowAndHighView: View {
  var lowTemperature: Measurement<UnitTemperature>
  var highTemperature: Measurement<UnitTemperature>

  var body: some View {
    HStack(spacing: 20.0) {
      Spacer()
      VStack {
        HStack(spacing: 5.0) {
          Image(systemName: "arrow.down")
            .font(.callout)
          Text(
            lowTemperature.formatted(
              .measurement(
                width: .narrow,
                usage: .weather))
          )
          .font(.callout)
        }
        Text("Low")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      VStack {
        HStack(spacing: 5.0) {
          Image(systemName: "arrow.up")
            .font(.callout)
          Text(
            highTemperature.formatted(
              .measurement(
                width: .narrow,
                usage: .weather))
          )
          .font(.callout)
        }
        Text("High")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      Spacer()
    }
  }
}

#if DEBUG
  struct WeatherLowAndHighView_Previews: PreviewProvider {
    static var previews: some View {
      WeatherLowAndHighView(
        lowTemperature: .init(value: 5, unit: .celsius),
        highTemperature: .init(value: 20, unit: .celsius))
    }
  }
#endif
