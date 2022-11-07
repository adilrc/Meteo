//
//  SettingsStore.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import Foundation

enum SettingsStore {
  static func store(_ settings: UserSettings) {
    UserDefaults.standard.set(settings, forKey: String(describing: UserSettings.self))
  }

  static func settings() -> UserSettings? {
    UserDefaults.standard.value(forKey: String(describing: UserSettings.self)) as? UserSettings
  }
}
