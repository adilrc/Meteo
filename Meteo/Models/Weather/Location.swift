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
}

extension Location {
  static let paris: Self = .init(
    locality: "Paris",
    latitude: 48.85679,
    longitude: 2.35108)
}
