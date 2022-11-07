//
//  WeatherContainerViewController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import Combine
import SwiftUI
import UIKit

/// Container for the selected location today's weather and the five days forecast.
final class WeatherContainerViewController<ViewModel: WeatherContainerViewModelType>: UIViewController {
  let viewModel: ViewModel

  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private lazy var containerStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.distribution = .fill
    stackView.alignment = .center
    stackView.axis = .vertical
    return stackView
  }()

  private lazy var largeTitle: UITextField = {
    let largeTitle = UITextField()
    largeTitle.isEnabled = false
    largeTitle.textAlignment = .left
    largeTitle.text = "My Location"
    largeTitle.font = .preferredFont(forTextStyle: .largeTitle, compatibleWith: .current)
    largeTitle.setContentHuggingPriority(.defaultLow, for: .horizontal)
    largeTitle.setContentHuggingPriority(.defaultHigh, for: .vertical)
    largeTitle.translatesAutoresizingMaskIntoConstraints = false
    return largeTitle
  }()

  private lazy var dateLabel: UITextField = {
    let label = UITextField()
    label.isEnabled = false
    label.textAlignment = .left
    label.text = "Now"
    label.font = .preferredFont(forTextStyle: .footnote, compatibleWith: .current)
    label.textColor = .secondaryLabel
    label.setContentHuggingPriority(.defaultHigh, for: .vertical)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var weatherSummaryView = WeatherSummaryView<ViewModel>(viewModel: viewModel)

  private lazy var weatherSummaryViewController = UIHostingController(rootView: weatherSummaryView)

  // - MARK: Forecast
  private lazy var forecastLabel: UITextField = {
    let label = UITextField()
    label.isEnabled = false
    label.textAlignment = .left
    label.text = "Five Day Forecast"
    label.font = .preferredFont(forTextStyle: .headline, compatibleWith: .current)
    label.setContentHuggingPriority(.defaultHigh, for: .vertical)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var forecastViewController = ForecastCollectionViewController(viewModel: viewModel)

  private func setupViewHierarchy() {
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(containerStackView)
    containerStackView.createConstraintsToFitInside(view)

    containerStackView.addArrangedSubview(largeTitle)
    largeTitle.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
      .tagAndActivate()
    largeTitle.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
      .tagAndActivate()

    containerStackView.addArrangedSubview(dateLabel)
    dateLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
      .tagAndActivate()
    dateLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
      .tagAndActivate()

    addChild(weatherSummaryViewController)

    containerStackView.addArrangedSubview(weatherSummaryViewController.view)
    weatherSummaryViewController.view.translatesAutoresizingMaskIntoConstraints = false
    weatherSummaryViewController.view.leadingAnchor.constraint(
      equalTo: view.layoutMarginsGuide.leadingAnchor
    ).tagAndActivate()
    weatherSummaryViewController.view.trailingAnchor.constraint(
      equalTo: view.layoutMarginsGuide.trailingAnchor
    ).tagAndActivate()

    containerStackView.addArrangedSubview(forecastLabel)
    forecastLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
      .tagAndActivate()
    forecastLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
      .tagAndActivate()

    addChild(forecastViewController)

    containerStackView.addArrangedSubview(forecastViewController.view)
    forecastViewController.view.translatesAutoresizingMaskIntoConstraints = false
    forecastViewController.view.leadingAnchor.constraint(
      equalTo: containerStackView.leadingAnchor
    ).tagAndActivate()
    forecastViewController.view.trailingAnchor.constraint(
      equalTo: containerStackView.trailingAnchor
    ).tagAndActivate()
    forecastViewController.view.bottomAnchor.constraint(
      equalTo: containerStackView.bottomAnchor
    ).tagAndActivate()
    forecastViewController.view.heightAnchor.constraint(
      equalToConstant: 200
    ).tagAndActivate()
  }

  private var subscriptions = Set<AnyCancellable>()
  private func subscribe(to viewModel: ViewModel) {
    viewModel
      .weatherWrapperPublisher
      .sink { [weak self] wrapper in
        guard let self = self, let locality = wrapper?.location.locality else { return }
        self.largeTitle.text = locality
      }
      .store(in: &subscriptions)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViewHierarchy()
    subscribe(to: viewModel)
  }
}
