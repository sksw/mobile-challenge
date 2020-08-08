//
//  ProductDataStoring.swift
//  Listings
//
//  Created by Steven Wu on 2020-07-14.
//  Copyright © 2020 Steven Wu. All rights reserved.
//

import Foundation
import RxSwift

protocol ProductDataStoring {
    func fetchProducts() -> Single<[Product]>
    func store(products: [Product]) -> Single<Void>
}

final class ProductDataStore {
    static let productsStorageKey = "products_key"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}

extension ProductDataStore: ProductDataStoring {
    func fetchProducts() -> Single<[Product]> {
        return Single.create { [weak self] subscriber in
            guard let self = self else { return Disposables.create() }
            do {
                let raw = self.userDefaults.data(forKey: ProductDataStore.productsStorageKey)!
                let products = try JSONDecoder().decode([Product].self, from: raw)
                subscriber(.success(products))
            } catch {
                subscriber(.error(error))
            }
            return Disposables.create()
        }
    }

    func store(products: [Product]) -> Single<Void> {
        return Single.create { [weak self] subscriber in
            guard let self = self else { return Disposables.create() }
            do {
                let serialized = try JSONEncoder().encode(products)
                self.userDefaults.set(serialized, forKey: ProductDataStore.productsStorageKey)
                subscriber(.success(()))
            } catch {
                subscriber(.error(error))
            }
            return Disposables.create()
        }
    }
}
