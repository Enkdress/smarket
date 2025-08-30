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
                    VStack(alignment: .leading, spacing: 12) {
                        Text(formattedCurrency(totalMonthly))
                            .font(.largeTitle)
                            .bold()
                        if let s = settings.first, s.budgetEnabled, s.budgetAmount > 0 {
                            let clamped = min(totalMonthly, s.budgetAmount)
                            ProgressView(value: clamped, total: s.budgetAmount) {
                                Text("Budget progress")
                            } currentValueLabel: {
                                Text("\(Int((totalMonthly / max(1, s.budgetAmount)) * 100))%")
                            }
                            .tint(totalMonthly <= s.budgetAmount ? .green : .orange)
                        }
                    }
                }

                if let s = settings.first, s.budgetEnabled {
                    Section("Budget") {
                        let over = totalMonthly >= s.budgetAmount
                        HStack {
                            Text("Budget")
                            Spacer()
                            Text(formattedCurrency(s.budgetAmount))
                        }
                        Group {
                            if over {
                                Label("Estimated spend meets or exceeds your budget", systemImage: "exclamationmark.triangle")
                                    .foregroundStyle(.orange)
                            } else {
                                Label("You're within budget", systemImage: "checkmark.circle")
                                    .foregroundStyle(.green)
                            }
                        }
                        .font(.subheadline)
                        .padding(.top, 4)
                        NavigationLink("Adjust budget in Settings", value: NavigationTarget.settings)
                    }
                }
            }
            .navigationTitle("Insights")
            .navigationDestination(for: NavigationTarget.self) { target in
                switch target {
                case .settings:
                    SettingsView()
                }
            }
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

private enum NavigationTarget: Hashable {
    case settings
}


