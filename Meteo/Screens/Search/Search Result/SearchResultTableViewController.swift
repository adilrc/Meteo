//
//  SearchResultTableViewController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import UIKit
import SwiftUI

private let searchResultCellReuseIdentifier = "SearchResultCell"

final class SearchResultTableViewController: UITableViewController {

  private lazy var dataSource: UITableViewDiffableDataSource<Int, Location> = .init(tableView: tableView) { tableView, indexPath, itemIdentifier in
    let cell = tableView.dequeueReusableCell(withIdentifier: searchResultCellReuseIdentifier)
    
    cell?.textLabel?.text = itemIdentifier.locality

    return cell
  }
  
  fileprivate var searchTask: Task<Void, Error>?
  
  private func registerCells() {
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: searchResultCellReuseIdentifier)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    registerCells()
  }
}

extension SearchResultTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    guard let input = searchController.searchBar.text, !input.isEmpty else { return }
  
    searchTask = Task { @MainActor in
      let locations = try await LocationAPI.shared.search(input)
      
      logger.info("􀊫 Found \(locations.count) locations.")
      
      var snapshot = NSDiffableDataSourceSnapshot<Int, Location>()
      snapshot.appendSections([0])
      snapshot.appendItems(locations)
      await dataSource.apply(snapshot)
    }
  }
}
