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
    func tag(
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
    func tagAndActivate(
        name: String? = nil, file: String = #file, function: String = #function, line: Int = #line
    ) -> Self {
        tag(name: name, file: file, function: function, line: line)
        return activate()
    }

    /// Activate the given constraint. Make sure the constraint is part of the view hierarchy or
    /// calling this method could lead to a crash.
    @discardableResult
    func activate() -> Self {
        isActive = true
        return self
    }
}

extension UILayoutGuide {
    /// Debugging utility to tag a constraint with a name, as well as file/line/function
    /// This identifier is used when constraints are printed to the console (e.g. during conflicts))
    @discardableResult
    func tag(
        name: String? = nil, file: String = #file, function: String = #function, line: Int = #line
    ) -> Self {
        identifier = .init(
            name.map { "\($0): \(file), \(line), \(function)" } ?? "\(file), \(line), \(function)")
        return self
    }
}
