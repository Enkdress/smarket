import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \Product.name) private var products: [Product]
    @Query private var settings: [AppSettings]

    private var totalMonthly: Double {
        products.reduce(0.0) { $0 + $1.monthlyCostEstimate }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Monthly estimate") {
                    Text(formattedCurrency(totalMonthly))
                        .font(.largeTitle)
                        .bold()
                }

                if let s = settings.first, s.budgetEnabled {
                    Section("Budget") {
                        let over = totalMonthly >= s.budgetAmount
                        HStack {
                            Text("Budget")
                            Spacer()
                            Text(formattedCurrency(s.budgetAmount))
                        }
                        if over {
                            Label("Estimated spend meets or exceeds your budget", systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
            .navigationTitle("Insights")
        }
    }

    private func formattedCurrency(_ value: Double) -> String {
        let number = NSNumber(value: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = (settings.first?.currency.rawValue) ?? "COP"
        return formatter.string(from: number) ?? "—"
    }
}


