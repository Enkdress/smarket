import Foundation
import SwiftData

@MainActor
final class CurrencyFormatterProvider: ObservableObject {
    private var formatter = NumberFormatter()
    private var currentCode: String = "COP"

    init() {
        formatter.numberStyle = .currency
        formatter.currencyCode = currentCode
    }

    func string(for decimal: Decimal, code: String) -> String {
        if currentCode != code {
            currentCode = code
            formatter.currencyCode = code
        }
        return formatter.string(from: NSDecimalNumber(decimal: decimal)) ?? "—"
    }
}


