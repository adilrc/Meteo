//
//  SearchResultTableViewController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import Combine
import UIKit

private let searchResultCellReuseIdentifier = "SearchResultCell"

final class SearchResultTableViewController: UITableViewController {

  private lazy var dataSource: UITableViewDiffableDataSource<Int, Location> = .init(
    tableView: tableView
  ) { tableView, indexPath, itemIdentifier in
    let cell = tableView.dequeueReusableCell(withIdentifier: searchResultCellReuseIdentifier)
    cell?.textLabel?.text = itemIdentifier.description
    return cell
  }

  private var subscriptions = Set<AnyCancellable>()

  private func registerCells() {
    tableView.register(
      UITableViewCell.self, forCellReuseIdentifier: searchResultCellReuseIdentifier)
  }

  private var emptySnapshot: NSDiffableDataSourceSnapshot<Int, Location> {
    var snapshot = NSDiffableDataSourceSnapshot<Int, Location>()
    snapshot.appendSections([0])
    snapshot.appendItems([])
    return snapshot
  }

  private func listenSearchBarChange() {
    NotificationCenter.default.publisher(
      for: UISearchTextField.textDidChangeNotification,
      object: (parent as? SearchTabViewController)?.searchController.searchBar.searchTextField
    )
    .compactMap { notification -> String? in
      (notification.object as? UISearchTextField)?.text
    }
    .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
    .sink { [weak self] value in
      guard let self = self else { return }
      Task { @MainActor in
        guard !value.isEmpty else {
          await self.dataSource.apply(self.emptySnapshot)
          return
        }

        let locations: Set<Location> = try await OpenWeatherAPI.shared.search(value)

        logger.info("􀊫 Found \(locations.count) locations.")

        var snapshot = NSDiffableDataSourceSnapshot<Int, Location>()
        snapshot.appendSections([0])
        snapshot.appendItems(locations.sorted())
        await self.dataSource.apply(snapshot)
      }
    }
    .store(in: &subscriptions)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    registerCells()
    listenSearchBarChange()
  }
}
