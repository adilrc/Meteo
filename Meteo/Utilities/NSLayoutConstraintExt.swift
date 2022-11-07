//
//  NSLayoutConstraintExt.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import UIKit

extension NSLayoutConstraint {
  /// Debugging utility to tag a constraint with a name, as well as file/line/function
  /// This identifier is used when constraints are printed to the console (e.g. during conflicts))
  @discardableResult
  public func tag(
    name: String? = nil, file: String = #file, function: String = #function, line: Int = #line
  ) -> Self {
    identifier =
      name.map { "\($0): file: \(file), line: \(line), function: \(function)" }
      ?? "file: \(file), line: \(line), function: \(function)"
    return self
  }

  /// Debugging utility to tag a constraint with a name, as well as file/line/function
  /// This identifier is used when constraints are printed to the console (e.g. during conflicts))
  @discardableResult
  public func tagAndActivate(
    name: String? = nil, file: String = #file, function: String = #function, line: Int = #line
  ) -> Self {
    tag(name: name, file: file, function: function, line: line)
    return activate()
  }

  @discardableResult
  public func activate() -> Self {
    isActive = true
    return self
  }
}

extension UILayoutGuide {
  /// Debugging utility to tag a constraint with a name, as well as file/line/function
  /// This identifier is used when constraints are printed to the console (e.g. during conflicts))
  @discardableResult
  public func tag(
    name: String? = nil, file: String = #file, function: String = #function, line: Int = #line
  ) -> Self {
    identifier = .init(
      name.map { "\($0): \(file), \(line), \(function)" } ?? "\(file), \(line), \(function)")
    return self
  }
}
