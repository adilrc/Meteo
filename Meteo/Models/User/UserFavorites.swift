//
//  UserFavorites.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import Foundation

struct UserFavorites: Codable, Hashable {
    let locations: [Location]
}

extension UserFavorites: CustomStringConvertible {
    var description: String {
        let locationsList = locations.map { "\t- \($0.locality)\n" }.joined()
        return "Locations:\n" + locationsList
    }
}
