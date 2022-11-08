//  SearchTabViewController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import UIKit

final class SearchTabViewController: UIViewController {

  private func setupView() {
    view.backgroundColor = .systemBackground

    addChild(searchContainerViewController)
    view.addSubview(searchContainerViewController.view)
    searchContainerViewController.view.createConstraintsToFitInside(view)
  }

  private lazy var viewModel = SearchContainerViewModel()

  private lazy var searchResultViewController = SearchResultTableViewController(viewModel: viewModel)

  lazy var searchController = UISearchController(
    searchResultsController: searchResultViewController)

  private lazy var searchContainerViewController = SearchContainerViewController(viewModel: viewModel)

  func openFavoriteSheet(_ location: Location) {
    let sheetViewController = AddFavoriteSheetPresentationController<WeatherContainerViewModel>(viewModel: .init(selectedLocation: location))
    sheetViewController.delegate = self
    guard let sheet = sheetViewController.sheetPresentationController else { return }
    sheet.detents = [.large()]
    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
    present(sheetViewController, animated: false)
  }

  private func setupSearchController() {
    searchResultViewController.parentController = self
    navigationItem.searchController = searchController
    searchController.searchBar.placeholder = "Search for a city or airport"
    searchController.obscuresBackgroundDuringPresentation = true
    definesPresentationContext = true
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupSearchController()
  }
}

extension SearchTabViewController: AddFavoriteSheetPresentationControllerDelegate {
  func addFavoriteSheet<ViewModel: WeatherContainerViewModelType>(
    _ controller: AddFavoriteSheetPresentationController<ViewModel>, didAdd location: Location
  ) {
    searchController.isActive = false
    viewModel.addFavorite(location)
    searchContainerViewController.favoritesCollectionViewController.addAndReloadFavorite(location)
  }
}
