//
//  SearchTabViewController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import UIKit

final class SearchTabViewController: UIViewController {
  //  override func loadView() {
  //    super.loadView()
  //    view = UIView(frame: UIScreen.main.bounds)
  //  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    let textField = UITextField()
    textField.text = "Search"
    textField.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(textField)
    textField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    textField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
}
