import Foundation
import SwiftData

@MainActor
enum PreviewSeed {
    static func seedIfEmpty(_ context: ModelContext) {
        let fetchProducts = FetchDescriptor<Product>()
        let existing = (try? context.fetch(fetchProducts)) ?? []
        if !existing.isEmpty { return }

        let products: [Product] = [
            Product(name: "Milk 1L", priceLatest: 4500, lastsDays: 3, lastPurchasedAt: daysAgo(2), category: .beverages),
            Product(name: "Eggs (12)", priceLatest: 12000, lastsDays: 10, lastPurchasedAt: daysAgo(5), category: .food),
            Product(name: "Rice 1kg", priceLatest: 3800, lastsDays: 20, lastPurchasedAt: daysAgo(12), category: .food),
            Product(name: "Coffee 250g", priceLatest: 15000, lastsDays: 25, lastPurchasedAt: daysAgo(20), category: .beverages),
            Product(name: "Toilet paper (4)", priceLatest: 8000, lastsDays: 15, lastPurchasedAt: daysAgo(8), category: .household),
            Product(name: "Shampoo", priceLatest: 18000, lastsDays: 30, lastPurchasedAt: daysAgo(25), category: .personalCare),
            Product(name: "Dog food 2kg", priceLatest: 25000, lastsDays: 12, lastPurchasedAt: daysAgo(8), category: .petSupplies),
            Product(name: "Dish soap", priceLatest: 6500, lastsDays: 20, lastPurchasedAt: daysAgo(15), category: .cleaning)
        ]
        for p in products { context.insert(p) }

        let settings = AppSettings()
        context.insert(settings)

        try? context.save()
    }

    private static func daysAgo(_ d: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -d, to: .now) ?? .now
    }
}


