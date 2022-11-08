//
//  AddFavoriteSheetPresentationController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/7/22.
//

import UIKit

protocol AddFavoriteSheetPresentationControllerDelegate: AnyObject {
  func addFavoriteSheet<ViewModel: WeatherContainerViewModelType>(_ controller: AddFavoriteSheetPresentationController<ViewModel>, didAdd location: Location)
}

final class AddFavoriteSheetPresentationController<ViewModel: WeatherContainerViewModelType>: UIViewController {
  
  let viewModel: ViewModel
  weak var delegate: AddFavoriteSheetPresentationControllerDelegate?
  
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private lazy var containerStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .center
    stackView.axis = .vertical
    stackView.directionalLayoutMargins = .init(top: 20.0, leading: 0, bottom: 10.0, trailing: 0)
    return stackView
  }()
  
  @objc private func didClickCancelButton(_ sender: UIButton) {
    dismiss(animated: true)
  }
  
  private lazy var cancelButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Cancel", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.contentHorizontalAlignment = .left
    button.addTarget(self, action: #selector(didClickCancelButton), for: .touchUpInside)
    return button
  }()
  
  @objc private func didClickAddButton(_ sender: UIButton) {
    guard let location = viewModel.selectedLocation else { return }
    delegate?.addFavoriteSheet(self, didAdd: location)
    dismiss(animated: true)
  }
  
  private lazy var addButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Add", for: .normal)
    button.setTitleColor(UIColor.systemBlue, for: .normal)
    button.contentHorizontalAlignment = .right
    button.addTarget(self, action: #selector(didClickAddButton), for: .touchUpInside)
    return button
  }()
  
  private lazy var buttonStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.distribution = .fill
    stackView.alignment = .center
    stackView.axis = .horizontal
    
    stackView.addArrangedSubview(cancelButton)
    stackView.addArrangedSubview(addButton)
    
    stackView.heightAnchor.constraint(equalTo: cancelButton.heightAnchor).tagAndActivate()
    
    return stackView
  }()

  
  private lazy var weatherContainerViewController = WeatherContainerViewController(viewModel: viewModel)
  
  private func setupViewHierarchy() {
    view.layoutMargins.top = 10.0
    view.addSubview(containerStackView)
    containerStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).tagAndActivate()
    containerStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).tagAndActivate()
    containerStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).tagAndActivate()
    containerStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).tagAndActivate()
    
    containerStackView.addArrangedSubview(buttonStackView)
    buttonStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).tagAndActivate()
    buttonStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).tagAndActivate()
    
    containerStackView.addArrangedSubview(weatherContainerViewController.view)
    weatherContainerViewController.view.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor).tagAndActivate()
    weatherContainerViewController.view.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor).tagAndActivate()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setupViewHierarchy()
  }
}
