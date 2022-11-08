//
//  ForecastCollectionViewController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import SwiftUI
import UIKit

private let weatherSummaryCellReuseIdentifier = "WeatherSummaryCell"

final class ForecastCollectionViewController<ViewModel: WeatherContainerViewModelType>: UICollectionViewController {

  private let viewModel: ViewModel

  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private lazy var dataSource = UICollectionViewDiffableDataSource<Int, WeatherSummary?>(
    collectionView: collectionView
  ) { collectionView, indexPath, itemIdentifier in
    let cell: UICollectionViewCell = collectionView.dequeueReusableCell(
      withReuseIdentifier: weatherSummaryCellReuseIdentifier, for: indexPath)
    cell.contentConfiguration = UIHostingConfiguration {
      WeatherSummaryTile(
        date: itemIdentifier?.date ?? .now,
        weatherIconSystemName: itemIdentifier?.weatherIconSystemName ?? "sun.max.fill",
        temperature: itemIdentifier?.temperature ?? .init(value: 20, unit: UnitTemperature.celsius)
      )
      .redacted(reason: (itemIdentifier?.isPlaceholder == true) ? .placeholder : [])
    }

    return cell
  }

  private func makeCollectionViewLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .absolute(122),
      heightDimension: .absolute(142))
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: groupSize,
      subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 10.0
    section.contentInsets = .init(top: 20.0, leading: 20.0, bottom: 0, trailing: 20.0)

    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.scrollDirection = .horizontal

    let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)

    return layout
  }

  private lazy var layout = makeCollectionViewLayout()

  private func setupCollectionView() {
    collectionView.showsHorizontalScrollIndicator = false
  }

  private func registerCell() {
    collectionView.register(
      UICollectionViewCell.self,
      forCellWithReuseIdentifier: weatherSummaryCellReuseIdentifier)
  }

  private func setupPlaceholders() {
    // Adding placeholders
    var snapshot = NSDiffableDataSourceSnapshot<Int, WeatherSummary?>()
    snapshot.appendSections([0])
    // Adding a placeholder
    let placeholderSummaries = (1...5).map { _ in return WeatherSummary.placeholder }
    snapshot.appendItems(placeholderSummaries)
    dataSource.apply(snapshot)
  }

  private func loadContent() {
    // Loading the actual forecast
    Task { @MainActor in
      guard
        let forecast =
          try await viewModel
          .reloadForecast(
            locAPI: LocationAPI.shared,
            weatherAPI: OpenWeatherAPI.shared,
            force: false)
      else { return }

      var snapshot = NSDiffableDataSourceSnapshot<Int, WeatherSummary?>()
      snapshot.appendSections([0])
      // Adding a placeholder
      snapshot.appendItems(forecast.weatherSummaries)
      await dataSource.apply(snapshot)
    }
  }

  override func loadView() {
    self.view = UIView()
    let collectionView = UICollectionView(
      frame: .zero, collectionViewLayout: layout)
    self.collectionView = collectionView
    self.view = collectionView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
    registerCell()
    setupPlaceholders()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadContent()
  }
}
