import Foundation
import SwiftData

@Model
final class Product {
    var id: UUID
    var name: String
    var priceLatest: Double
    var lastsDays: Int
    var lastPurchasedAt: Date
    var notes: String?

    init(
        id: UUID = UUID(),
        name: String,
        priceLatest: Double,
        lastsDays: Int,
        lastPurchasedAt: Date,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.priceLatest = priceLatest
        self.lastsDays = max(1, lastsDays)
        self.lastPurchasedAt = lastPurchasedAt
        self.notes = notes
    }

    var nextRunOutDate: Date {
        Calendar.current.date(byAdding: .day, value: lastsDays, to: startOfDay(for: lastPurchasedAt)) ?? lastPurchasedAt
    }

    var dailyCost: Double {
        guard lastsDays > 0 else { return 0 }
        return priceLatest / Double(lastsDays)
    }

    var monthlyCostEstimate: Double {
        dailyCost * 30.0
    }

    private func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
}


