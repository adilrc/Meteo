//
//  SwiftUI+ShapeStyle.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/6/22.
//

import SwiftUI

enum CustomShapeStyle {
    static func primaryStyle(for systemName: String) -> some ShapeStyle {
        switch systemName {
            case "sun.max.fill", "moon.fill":
                return AnyShapeStyle(.yellow)
            default:
                return AnyShapeStyle(.quaternary)
        }
    }

    static func secondaryStyle(for systemName: String) -> some ShapeStyle {
        if systemName.contains("sun") || systemName.contains("bolt") {
            return AnyShapeStyle(.yellow)
        } else {
            return AnyShapeStyle(.cyan)
        }
    }
}
