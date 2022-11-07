//
//  RootTabBarController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import UIKit

/// The root view controller is a tab bar controller.
final class RootViewController: UITabBarController {

  private func setupTabBar() {
    viewControllers = AppTab.allCases.map {
      let rootViewController = $0.makeRootViewController()

      let navigationViewController = UINavigationController(rootViewController: rootViewController)

      navigationViewController.tabBarItem.title = $0.title
      navigationViewController.tabBarItem.image = $0.image

      return navigationViewController
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTabBar()
  }
}
