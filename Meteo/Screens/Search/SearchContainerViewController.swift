//
//  SearchContainerViewController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import UIKit

final class SearchContainerViewController<ViewModel: SearchContainerViewModelType>: UIViewController {

    private let viewModel: ViewModel

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
        largeTitle.text = "Favorites"
        largeTitle.font = .preferredFont(forTextStyle: .largeTitle, compatibleWith: .current)
        largeTitle.setContentHuggingPriority(.defaultLow, for: .horizontal)
        largeTitle.setContentHuggingPriority(.defaultHigh, for: .vertical)
        largeTitle.translatesAutoresizingMaskIntoConstraints = false
        return largeTitle
    }()

    private(set) lazy var favoritesCollectionViewController = FavoritesCollectionViewController<ViewModel>(
        viewModel: viewModel)

    private func setupViewHierarchy() {
        view.addSubview(containerStackView)
        containerStackView.createConstraintsToFitInside(view)

        containerStackView.addArrangedSubview(largeTitle)
        largeTitle.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
            .tagAndActivate()
        largeTitle.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
            .tagAndActivate()

        addChild(favoritesCollectionViewController)
        containerStackView.addArrangedSubview(favoritesCollectionViewController.view)
        favoritesCollectionViewController.view.leadingAnchor.constraint(
            equalTo: containerStackView.leadingAnchor
        )
        .tagAndActivate()
        favoritesCollectionViewController.view.trailingAnchor.constraint(
            equalTo: containerStackView.trailingAnchor
        )
        .tagAndActivate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
    }
}
