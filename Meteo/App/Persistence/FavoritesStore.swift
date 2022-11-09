//
//  FavoritesStore.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import Foundation

enum FavoritesStore {
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()

    static func store(_ favorites: UserFavorites, userDefault: UserDefaults = UserDefaults.standard) {
        logger.info("􀋃 Storing favorites:\n \(favorites.description)")
        let data = try? jsonEncoder.encode(favorites)
        userDefault.set(data, forKey: String(describing: UserFavorites.self))
    }

    static func favorites(userDefault: UserDefaults = UserDefaults.standard) -> UserFavorites? {
        guard
            let data = userDefault.data(forKey: String(describing: UserFavorites.self)),
            let favorites = try? jsonDecoder.decode(UserFavorites.self, from: data)
        else { return nil }

        logger.info("􀋃 Pulling user favorites:\n \(favorites.description)")
        return favorites
    }
}
