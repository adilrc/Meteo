//
//  AppTab.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import UIKit

enum AppTab: CaseIterable {
  case weather
  case search

  var title: String {
    switch self {
    case .weather:
      return "Weather"
    case .search:
      return "Search"
    }
  }

  var image: UIImage? {
    switch self {
    case .weather:
      return UIImage(systemName: "cloud.sun.fill")
    case .search:
      return UIImage(systemName: "magnifyingglass")
    }
  }

  func makeRootViewController() -> UIViewController {
    switch self {
    case .weather:
      return WeatherTabViewController()
    case .search:
      return SearchTabViewController()
    }
  }
}
