//
//  SearchResultTableViewController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import Combine
import UIKit

private let searchResultCellReuseIdentifier = "SearchResultCell"

final class SearchResultTableViewController<ViewModel: SearchContainerViewModelType>: UITableViewController {

  private let viewModel: ViewModel

  weak var parentController: SearchTabViewController?

  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
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
      object: (parent as? UISearchController)?.searchBar.searchTextField
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
    tableView.delegate = self
    registerCells()
    listenSearchBarChange()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let location = dataSource.snapshot().itemIdentifiers[indexPath.item]
    parentController?.openFavoriteSheet(location)
  }
}
