//
//  WeatherTabViewController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import UIKit

final class WeatherTabViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    let viewController = WeatherContainerViewController(viewModel: WeatherContainerViewModel())
    addChild(viewController)
    view.addSubview(viewController.view)
    viewController.view.createConstraintsToFitInside(view)
  }
}
