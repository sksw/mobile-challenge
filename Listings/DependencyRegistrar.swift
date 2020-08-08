//
//  DependencyModule.swift
//  Listings
//
//  Created by Steven Wu on 2020-06-27.
//  Copyright © 2020 Steven Wu. All rights reserved.
//

import Foundation
// swiftlint:disable:next injector_import
import Swinject
import Moya

extension DependencyRegistrar {
    var resolver: Resolver {
        return container
    }
}

final class DependencyRegistrar {
    fileprivate let container = Container(defaultObjectScope: .transient)

    init() {
        registerDependencies()
    }

    // swiftlint:disable force_unwrapping
    func registerDependencies() {
        // MARK: app level
        container.register(AppUIFactory.self) { AppUIFactory(with: $0) }
        container.register(AppCoordinator.self) { _ in AppCoordinator() }

        // MARK: products flow
        container.register(ProductsUIFactory.self) { ProductsUIFactory(with: $0) }
        container.register(ProductsDataServicing.self) { resolver in
            resolver.resolve(DataService.self)!
        }
        container.register(ProductListViewModel.self) { resolver in
            ProductListViewModel(
                with: resolver.resolve(ProductsDataServicing.self)!,
                localeProvider: resolver.resolve(Provider<Locale>.self)!
            )
        }
        container.register(MoyaProvider<ProductsAPI>.self) { _ in
            NetworkerFactory.make(for: ProductsAPI.self, with: AppSecrets.bearerToken)
        }

        // MARK: data
        container.register(DataService.self) { resolver in
            DataService(
                businessId: AppSecrets.businessId,
                productsAPI: resolver.resolve(MoyaProvider<ProductsAPI>.self)!,
                productStore: resolver.resolve(ProductDataStoring.self)!
            )
        }
        .inObjectScope(.container)

        container.register(ProductDataStoring.self) { _ in
            ProductDataStore(userDefaults: UserDefaults.standard)
        }

        // MARK: common
        container.register(Provider<Locale>.self) { _ in
            Provider<Locale> { Locale.current }
        }
    }
    // swiftlint:enable force_unwrapping
}
