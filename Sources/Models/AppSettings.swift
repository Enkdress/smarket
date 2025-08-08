import Foundation
import SwiftData

enum Currency: String, Codable, CaseIterable, Identifiable {
    case cop = "COP"
    case usd = "USD"

    var id: String { rawValue }
}

@Model
final class AppSettings {
    var id: UUID
    var currencyRawValue: String
    var headsUpDays: Int
    var reminderHour: Int
    var budgetEnabled: Bool
    var budgetAmount: Double
    var lastBudgetAlertAt: Date?

    init(
        id: UUID = UUID(),
        currency: Currency = .cop,
        headsUpDays: Int = 2,
        reminderHour: Int = 9,
        budgetEnabled: Bool = false,
        budgetAmount: Double = 0,
        lastBudgetAlertAt: Date? = nil
    ) {
        self.id = id
        self.currencyRawValue = currency.rawValue
        self.headsUpDays = headsUpDays
        self.reminderHour = reminderHour
        self.budgetEnabled = budgetEnabled
        self.budgetAmount = budgetAmount
        self.lastBudgetAlertAt = lastBudgetAlertAt
    }

    var currency: Currency {
        get { Currency(rawValue: currencyRawValue) ?? .cop }
        set { currencyRawValue = newValue.rawValue }
    }
}


