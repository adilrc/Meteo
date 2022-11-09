//
//  FavoritesStoreTests.swift
//  MeteoTests
//
//  Created by Adil Erchouk on 11/8/22.
//

import XCTest

@testable import Meteo

final class FavoritesStoreTests: XCTestCase {
    private let userDefault: UserDefaults = UserDefaults(suiteName: #file)!

    func testFavoritesStore() throws {
        let favorites = UserFavorites(locations: [.paris, .sanDiego])

        FavoritesStore.store(favorites, userDefault: userDefault)

        let storedFavorites = FavoritesStore.favorites(userDefault: userDefault)

        XCTAssertEqual(favorites, storedFavorites)
    }
}
