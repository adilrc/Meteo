//
//  UserSelectedLocation.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/7/22.
//

import Foundation

extension Notification.Name {
  static let userDidSelectLocation: Self = .init("UserDidSelectLocation")
}

enum UserSelectedLocation {
  static let key = "userSelectedLocationKey"
}
