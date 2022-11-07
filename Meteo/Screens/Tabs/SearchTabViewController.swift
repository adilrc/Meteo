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

  private lazy var searchResultViewController = SearchResultTableViewController()

  lazy var searchController = UISearchController(
    searchResultsController: searchResultViewController)

  private lazy var searchContainerViewController = SearchContainerViewController(
    viewModel: SearchContainerViewModel())

  private func setupSearchController() {
    navigationItem.searchController = searchController
    addChild(searchResultViewController)
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
