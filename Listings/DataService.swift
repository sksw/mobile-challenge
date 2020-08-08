//
//  DataService.swift
//  Listings
//
//  Created by Steven Wu on 2020-06-28.
//  Copyright © 2020 Steven Wu. All rights reserved.
//

import Foundation
import RxSwift
import Moya

final class DataService {

    // MARK: - fields

    private let bag = DisposeBag()
    fileprivate let _products = BehaviorSubject<[Product]>(value: [])

    // MARK: - dependencies & init

    private let businessId: String
    private let productsAPI: MoyaProvider<ProductsAPI>
    private let productStore: ProductDataStoring

    init(businessId: String,
         productsAPI: MoyaProvider<ProductsAPI>,
         productStore: ProductDataStoring) {
        self.businessId = businessId
        self.productsAPI = productsAPI
        self.productStore = productStore

        productStore.fetchProducts().subscribe(
            onSuccess: { [unowned self] products in
                self._products.on(.next(products))
                self.fetchProducts()
            })
            .disposed(by: bag)
    }

}

extension DataService: ProductsDataServicing {
    var products: BehaviorSubject<[Product]> {
        return _products
    }

    /// Fetch products for a business.
    /// - Parameter businessId: ID of the business to fetch products for.
    /// - Returns: Single resolving with a list of products – this is a HOT action.
    func fetchProducts() -> Single<[Product]> {
        let request = productsAPI.rx
            .request(.products(bid: businessId))
            .asObservable().share(replay: 1, scope: .forever)
            .asSingle()
            .filterSuccessfulStatusCodes()
            .map([Product].self)
            .flatMap { [unowned self] items in
                return self.productStore.store(products: items)
        }

        log.info("fetching products")
        request.subscribe(
            onSuccess: { [unowned self] products in
                self._products.on(.next(products))
                log.info("succesfully fetched \(products.count) products")
            }, onError: { error in
                log.error("failed fetching product on \(error)")
            })
            .disposed(by: bag)
        return request
    }
}
