//
//  DependencyModule.swift
//  Listings
//
//  Created by Steven Wu on 2020-06-27.
//  Copyright © 2020 Steven Wu. All rights reserved.
//

import Foundation
// swiftlint:disable:next restricted_access_to_injector
import Swinject
import Moya

extension DependencyRegistrar {
    internal var resolver: Resolver {
        return container
    }
}

final class DependencyRegistrar {
    fileprivate let container = Container(defaultObjectScope: .transient)

    init() {
        registerDependencies()
    }

    func registerDependencies() {
        // MARK: app level
        container.register(AppUIFactory.self) { AppUIFactory(with: $0) }
        container.register(AppCoordinator.self) { _ in AppCoordinator() }

        // MARK: products flow
        container.register(ProductsUIFactory.self) { ProductsUIFactory(with: $0) }
        container.register(ProductListViewModel.self) { _ in ProductListViewModel() }
        container.register(MoyaProvider<ProductsAPI>.self) { _ in
            ProductsAPI.provide(with: APIKeys.productsAuthToken)
        }

        // MARK: data
        container.register(DataService.self) { resolver in
            DataService(
                businessId: "89746d57-c25f-4cec-9c63-34d7780b044b",
                // swiftlint:disable:next force_unwrapping
                productsAPI: resolver.resolve(MoyaProvider<ProductsAPI>.self)!
            )
        }
    }
}
