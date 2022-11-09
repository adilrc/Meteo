//
//  UserSettings.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import Foundation

struct UserSettings {
    var degreesUnit: UnitTemperature = .init(forLocale: Locale.current)
}
