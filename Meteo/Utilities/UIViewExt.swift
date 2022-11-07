//
//  UIViewExt.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import UIKit

extension UIView {
  @discardableResult
  func createConstraintsToFitInside(
    _ parentView: UIView, spacing: CGFloat = 0, priority: UILayoutPriority = .required,
    activate: Bool = true, file: String = #file, function: String = #function, line: Int = #line
  ) -> [NSLayoutConstraint] {
    createConstraintsToFitInside(
      parentView, verticalSpacing: spacing, horizontalSpacing: spacing, priority: priority,
      activate: activate, file: file, function: function, line: line)
  }

  @discardableResult
  func createConstraintsToFitInside(
    _ parentView: UIView, verticalSpacing: CGFloat, horizontalSpacing: CGFloat,
    priority: UILayoutPriority = .required, activate: Bool = true, file: String = #file,
    function: String = #function, line: Int = #line
  ) -> [NSLayoutConstraint] {
    createConstraintsToFitInside(
      parentView, topSpacing: verticalSpacing, bottomSpacing: verticalSpacing,
      leadingSpacing: horizontalSpacing, trailingSpacing: horizontalSpacing, priority: priority,
      activate: activate, file: file, function: function, line: line)
  }

  @discardableResult
  func createConstraintsToFitInside(
    _ parentView: UIView, topSpacing: CGFloat, bottomSpacing: CGFloat, leadingSpacing: CGFloat,
    trailingSpacing: CGFloat, priority: UILayoutPriority = .required, activate: Bool = true,
    file: String = #file, function: String = #function, line: Int = #line
  ) -> [NSLayoutConstraint] {
    if activate {
      translatesAutoresizingMaskIntoConstraints = false
    }

    let margins = parentView.layoutMarginsGuide

    let leadingConstraint = leadingAnchor.constraint(
      equalTo: parentView.leadingAnchor, constant: leadingSpacing)
    leadingConstraint.tag(name: "leading", file: file, function: function, line: line)
    let trailingConstraint = trailingAnchor.constraint(
      equalTo: parentView.trailingAnchor, constant: -trailingSpacing)
    trailingConstraint.tag(name: "trailing", file: file, function: function, line: line)
    let bottomConstraint = bottomAnchor.constraint(
      equalTo: margins.bottomAnchor, constant: -bottomSpacing)
    bottomConstraint.tag(name: "bottom", file: file, function: function, line: line)
    let topConstraint = topAnchor.constraint(equalTo: margins.topAnchor, constant: topSpacing)
    topConstraint.tag(name: "top", file: file, function: function, line: line)

    let result = [
      leadingConstraint,
      trailingConstraint,
      bottomConstraint,
      topConstraint,
    ]

    result.forEach {
      $0.priority = priority
      $0.isActive = activate
    }

    return result
  }

  @discardableResult
  func createConstraintsToCenterViewInside(
    _ parentView: UIView, priority: UILayoutPriority = .required, activate: Bool = true,
    file: String = #file, function: String = #function, line: Int = #line
  ) -> [NSLayoutConstraint] {
    if activate {
      translatesAutoresizingMaskIntoConstraints = false
    }

    let horizontalConstraint = centerXAnchor.constraint(equalTo: parentView.centerXAnchor)
    horizontalConstraint.tag(name: "centerX", file: file, function: function, line: line)

    let verticalConstraint = centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
    verticalConstraint.tag(name: "centerY", file: file, function: function, line: line)

    let result = [horizontalConstraint, verticalConstraint]

    result.forEach {
      $0.priority = priority
      $0.isActive = activate
    }

    return result
  }
}
