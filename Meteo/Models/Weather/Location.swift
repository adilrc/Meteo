//
//  Location.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import Foundation

struct Location: Codable, Hashable {
  let locality: String
  let latitude: Double
  let longitude: Double
  var countryCode: String?
  var state: String?

  init(locality: String, latitude: Double, longitude: Double, countryCode: String? = nil, state: String? = nil) {
    self.locality = locality
    self.latitude = latitude
    self.longitude = longitude
    self.countryCode = countryCode
    self.state = state
  }

  var isCurrentLocation: Bool = false

  mutating func setAsCurrentLocation() {
    self.isCurrentLocation = true
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(description)
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.description == rhs.description
  }
}

extension Location: CustomStringConvertible {
  var description: String {
    var label = "\(locality)"

    if let state = state {
      label.append(", " + state)
    }

    if let countryCode = countryCode {
      label.append(", " + countryCode)
    }

    return label
  }
}

extension Location: Comparable {
  static func < (lhs: Location, rhs: Location) -> Bool {
    return lhs.description < rhs.description
  }
}

extension Location {
  static let paris: Self = .init(
    locality: "Paris",
    latitude: 48.85679,
    longitude: 2.35108,
    countryCode: "FR",
    state: "Ile-de-France")

  static let london: Self = .init(
    locality: "London",
    latitude: 51.500956,
    longitude: -0.125434,
    countryCode: "UK")

  static let sanDiego: Self = .init(
    locality: "San Diego",
    latitude: 32.711516,
    longitude: -117.163129,
    countryCode: "US")
}
