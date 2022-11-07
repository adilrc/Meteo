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
    longitude: 2.35108)
}
