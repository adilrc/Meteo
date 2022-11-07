//
//  FavoritesCollectionViewController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import SwiftUI
import UIKit

private let favoritesCellReuseIdentifier = "FavoritesCell"

final class FavoritesCollectionViewController: UICollectionViewController {

  private let viewModel: SearchContainerViewModelType

  init(viewModel: SearchContainerViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func makeCollectionViewLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(122))
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 10.0
    section.contentInsets = .init(top: 20.0, leading: 0, bottom: 0, trailing: 0)

    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.scrollDirection = .vertical

    let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)

    return layout
  }

  private lazy var layout = makeCollectionViewLayout()

  private lazy var dataSource = UICollectionViewDiffableDataSource<Int, WeatherWrapper>(
    collectionView: collectionView
  ) { collectionView, indexPath, itemIdentifier in
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: favoritesCellReuseIdentifier, for: indexPath)

    cell.contentConfiguration = UIHostingConfiguration {
      FavoriteTileView(
        isCurrentLocation: true,
        locality: itemIdentifier.location.locality,
        dateStringAtLocation: "12:00 p.m.",
        weatherIconSystemName: itemIdentifier.weatherSummary.weatherIconSystemName,
        description: itemIdentifier.weatherSummary.description ?? "",
        temperature: itemIdentifier.weatherSummary.temperature)
    }

    return cell
  }

  private func registerCells() {
    collectionView.register(
      UICollectionViewCell.self, forCellWithReuseIdentifier: favoritesCellReuseIdentifier)
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
    registerCells()

    var snaphot = NSDiffableDataSourceSnapshot<Int, WeatherWrapper>()
    snaphot.appendSections([0])
    snaphot.appendItems([
      .init(
        weatherSummary: .init(
          date: .now,
          weatherIconSystemName: "cloud.sun.fill",
          temperature: .init(value: 20, unit: .celsius),
          lastUpdate: .now,
          isPlaceholder: false),
        location: .init(
          locality: "Paris",
          latitude: 0,
          longitude: 0))
    ])

    dataSource.apply(snaphot)
  }
}
