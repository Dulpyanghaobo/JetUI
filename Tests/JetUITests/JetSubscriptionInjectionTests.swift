import StoreKit
import XCTest
@testable import JetUI

final class JetSubscriptionInjectionTests: XCTestCase {
    func testStoreServiceFetchesProductsFromExplicitConfigInsteadOfGlobalConfig() async throws {
        let globalConfig = JetSubscriptionConfig(
            productIds: ["global_weekly"],
            proProductIds: ["global_weekly"],
            groupId: "global",
            appIdentifier: "global.app"
        )

        await MainActor.run {
            JetUI.configureSubscription(globalConfig)
        }

        let explicitConfig = JetSubscriptionConfig(
            productIds: ["explicit_weekly", "explicit_yearly"],
            proProductIds: ["explicit_weekly", "explicit_yearly"],
            groupId: "explicit",
            appIdentifier: "explicit.app"
        )
        let catalog = CapturingProductCatalog()
        let service = JetStoreService(
            config: explicitConfig,
            productCatalog: catalog
        )

        let products = try await service.fetchProducts()

        XCTAssertTrue(products.isEmpty)
        XCTAssertEqual(await catalog.requestedProductIds, explicitConfig.productIds)
    }

    @MainActor
    func testSubscriptionRuntimeCreatesManagerWithInjectedStoreService() async {
        let config = JetSubscriptionConfig(
            productIds: ["runtime_weekly"],
            proProductIds: ["runtime_weekly"],
            groupId: "runtime",
            appIdentifier: "runtime.app"
        )
        let storeService = SpyStoreService()

        let runtime = JetSubscriptionRuntime(
            config: config,
            storeService: storeService
        )

        await runtime.manager.load()

        XCTAssertEqual(await storeService.fetchProductsCallCount, 1)
        XCTAssertEqual(await storeService.isEntitledToProCallCount, 1)
    }
}

private actor CapturingProductCatalog: JetProductCatalog {
    private(set) var requestedProductIds: [String]?

    func products(for ids: [String]) async throws -> [Product] {
        requestedProductIds = ids
        return []
    }
}

private actor SpyStoreService: JetStoreServiceProtocol {
    private(set) var fetchProductsCallCount = 0
    private(set) var isEntitledToProCallCount = 0

    func fetchProducts() async throws -> [Product] {
        fetchProductsCallCount += 1
        return []
    }

    func purchase(_ product: Product) async throws -> (Transaction, String) {
        throw JetStoreError.unknown
    }

    func restorePurchases() async throws {}

    func currentEntitlements() async throws -> [Transaction] {
        []
    }

    func isEntitledToPro() async -> Bool {
        isEntitledToProCallCount += 1
        return true
    }
}
