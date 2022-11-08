//
//  FavoritesCollectionViewController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import Combine
import SwiftUI
import UIKit

private let favoritesCellReuseIdentifier = "FavoritesCell"

final class FavoritesCollectionViewController<ViewModel: SearchContainerViewModelType>: UICollectionViewController {

  private let viewModel: ViewModel

  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func delete(_ weatherWrapper: WeatherWrapper) {
    // Remove from user favorites database
    viewModel.removeFavorite(weatherWrapper.location)

    // Remove from the list
    var snapshot = dataSource.snapshot()
    snapshot.deleteItems([weatherWrapper])
    dataSource.apply(snapshot)
  }

  private func selectWeatherWrapper(_ wrapper: WeatherWrapper) {
    NotificationCenter.default.post(
      name: .userDidSelectLocation,
      object: self,
      userInfo: [UserSelectedLocation.key: wrapper])
  }

  private lazy var dataSource = UICollectionViewDiffableDataSource<Int, WeatherWrapper>(
    collectionView: collectionView
  ) { collectionView, indexPath, itemIdentifier in
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: favoritesCellReuseIdentifier, for: indexPath)

    cell.contentConfiguration = UIHostingConfiguration { [weak self] in
      FavoriteTileView(
        isCurrentLocation: itemIdentifier.location.isCurrentLocation,
        locality: itemIdentifier.location.locality,
        dateStringAtLocation: ViewModel.timeLabel(for: itemIdentifier.weatherSummary),
        weatherIconSystemName: itemIdentifier.weatherSummary.weatherIconSystemName,
        description: itemIdentifier.weatherSummary.description ?? "",
        temperature: itemIdentifier.weatherSummary.temperature,
        isPlaceholder: itemIdentifier.weatherSummary.isPlaceholder
      )
      .redacted(reason: itemIdentifier.weatherSummary.isPlaceholder ? .placeholder : [])
      .swipeActions(edge: SwiftUI.HorizontalEdge.trailing, allowsFullSwipe: true) {
        Button {
          self?.delete(itemIdentifier)
        } label: {
          Text("Delete")
        }
        .tint(.red)
      }
      .onTapGesture {
        self?.selectWeatherWrapper(itemIdentifier)
      }
    }

    return cell
  }

  @objc private func refresh(_ sender: UIRefreshControl) {
    refresh(dataSource.snapshot().itemIdentifiers, force: true)
  }

  private lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return refreshControl
  }()

  private func registerCells() {
    collectionView.register(
      UICollectionViewCell.self, forCellWithReuseIdentifier: favoritesCellReuseIdentifier)
  }

  var setupPlaceholdersTask: Task<Void, Error>?

  @MainActor
  private func setupPlaceholders() {
    setupPlaceholdersTask = Task {
      // Fetch locations
      let locations = try await self.viewModel.reloadFavoriteLocations()

      // Create placeholders
      let placeholderWeatherWrappers = locations.map { WeatherWrapper(weatherSummary: .placeholder, location: $0) }

      // Populate placeholders
      var placeholderSnaphot = NSDiffableDataSourceSnapshot<Int, WeatherWrapper>()
      placeholderSnaphot.appendSections([0])
      placeholderSnaphot.appendItems(placeholderWeatherWrappers)
      await dataSource.apply(placeholderSnaphot)
    }
  }

  @MainActor
  private func refresh(_ wrappers: [WeatherWrapper], force: Bool = false) {
    Task {
      // Fetch weather wrappers
      guard let results = try await viewModel.refresh(wrappers, force: force, priority: .utility) else { return }

      var weatherSnapshot = dataSource.snapshot()

      var itemsToReconfigure: [WeatherWrapper] = []
      var itemsToDelete: [WeatherWrapper] = []
      for result in results {
        switch result {
          case let .success(wrapper):
            // Populate placeholders with weather
            itemsToReconfigure.append(wrapper)
          case let .failure(OpenWeatherAPIError.cannotProvideForecast(location: location)):
            // Drop errored items
            let items = weatherSnapshot.itemIdentifiers.filter { $0.location == location }
            itemsToDelete.append(contentsOf: items)
          default:
            break
        }
      }

      weatherSnapshot.reconfigureItems(itemsToReconfigure)
      weatherSnapshot.deleteItems(itemsToDelete)

      await dataSource.apply(weatherSnapshot)
      refreshControl.endRefreshing()
    }
  }

  override func loadView() {
    self.view = UIView()
    var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
    layoutConfig.showsSeparators = false
    let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
    collectionView.refreshControl = refreshControl
    self.collectionView = collectionView
    self.view = collectionView
  }

  private var subscriptions = Set<AnyCancellable>()

  func addAndReloadFavorite(_ location: Location) {
    // Add placeholder item
    var placeholderSnapshot = self.dataSource.snapshot()
    let placeholder = WeatherWrapper(weatherSummary: .placeholder, location: location)
    placeholderSnapshot.appendItems([placeholder])
    self.dataSource.apply(placeholderSnapshot, animatingDifferences: true)

    // Populate placeholder item
    Task { @MainActor in
      guard let weatherWrapper = try await self.viewModel.refresh([placeholder], force: true, priority: .utility)?.first?.get() else { return }
      var snapshot = self.dataSource.snapshot()
      snapshot.reconfigureItems([weatherWrapper])
      await self.dataSource.apply(snapshot)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    registerCells()
    setupPlaceholders()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Task {
      _ = await setupPlaceholdersTask?.result
      refresh(dataSource.snapshot().itemIdentifiers)
    }
  }
}
