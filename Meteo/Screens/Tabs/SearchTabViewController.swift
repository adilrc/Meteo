//  SearchTabViewController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import UIKit

final class SearchTabViewController: UIViewController {

  private func setupView() {
    view.backgroundColor = .systemBackground
  }
  
  
  private lazy var searchResultViewController = SearchResultTableViewController()
  
  private lazy var searchController = UISearchController(searchResultsController: searchResultViewController)

  
  private func setupSearchController() {
    navigationItem.searchController = searchController
    searchController.searchResultsUpdater = searchResultViewController
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
