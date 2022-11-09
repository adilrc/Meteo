//
//  WeatherFocusView.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import SwiftUI

/// View representing the current weather with an icon and the temperature.
struct WeatherFocusView: View {
    var weatherIconSystemName: String
    var temperature: Measurement<UnitTemperature>

    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: weatherIconSystemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120)
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    CustomShapeStyle.primaryStyle(for: weatherIconSystemName),
                    CustomShapeStyle.secondaryStyle(for: weatherIconSystemName))
            Text(
                temperature.formatted(
                    .measurement(width: .narrow, usage: .weather))
            )
            .font(.system(size: 40))
            .fontWeight(.bold)
        }
    }
}

#if DEBUG
    struct WeatherFocusView_Previews: PreviewProvider {
        static var previews: some View {
            WeatherFocusView(
                weatherIconSystemName: "moon.fill", temperature: .init(value: 20, unit: .celsius)
            )
        }
    }
#endif
