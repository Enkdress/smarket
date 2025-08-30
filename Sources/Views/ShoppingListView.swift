import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct ShoppingListView: View {
    @Environment(\.modelContext) private var context
    @Query private var allProducts: [Product]
    @Query private var settings: [AppSettings]

    private var headsUpDays: Int { settings.first?.headsUpDays ?? 2 }
    private var currencyCode: String { settings.first?.currency.rawValue ?? "COP" }

    private var products: [Product] {
        allProducts.sorted { $0.name < $1.name }
    }

    private var dueSoon: [Product] {
        let now = Calendar.current.startOfDay(for: .now)
        let filtered = products.filter { product in
            let days = Calendar.current.dateComponents([.day], from: now, to: product.nextRunOutDate).day ?? 0
            return days <= headsUpDays
        }
        return filtered.sorted { $0.nextRunOutDate < $1.nextRunOutDate }
    }

    private var totalMonthly: Double {
        products.reduce(0.0) { $0 + $1.monthlyCostEstimate }
    }

    private var tripSubtotal: Double {
        dueSoon.reduce(0) { $0 + $1.priceLatest }
    }

    var body: some View {
        NavigationStack {
            if dueSoon.isEmpty {
                ContentUnavailableView("All set", systemImage: "checkmark.seal", description: Text("Nothing due in the next \(headsUpDays) days"))
                    .navigationTitle("Shopping")
            } else {
                List {
                    Section(header: Text("Trip summary")) {
                        HStack {
                            Text("Items")
                            Spacer()
                            Text("\(dueSoon.count)")
                        }
                        HStack {
                            Text("Subtotal")
                            Spacer()
                            Text(formattedCurrency(tripSubtotal))
                        }
                        if let s = settings.first, s.budgetEnabled, s.budgetAmount > 0 {
                            let remaining = s.budgetAmount - totalMonthly
                            HStack {
                                Text("Budget remaining")
                                Spacer()
                                Text(formattedCurrency(remaining))
                                    .foregroundStyle(remaining >= 0 ? Color.secondary : .orange)
                            }
                        }
                    }
                    
                    let categorizedProducts = categorizeProducts()
                    
                    if !categorizedProducts.overdue.isEmpty {
                        Section(header: Text("Overdue")) {
                            ForEach(categorizedProducts.overdue) { product in
                                productRow(product)
                            }
                        }
                    }
                    
                    if !categorizedProducts.today.isEmpty {
                        Section(header: Text("Today")) {
                            ForEach(categorizedProducts.today) { product in
                                productRow(product)
                            }
                        }
                    }
                    
                    if !categorizedProducts.tomorrow.isEmpty {
                        Section(header: Text("Tomorrow")) {
                            ForEach(categorizedProducts.tomorrow) { product in
                                productRow(product)
                            }
                        }
                    }
                    
                    if !categorizedProducts.soon.isEmpty {
                        Section(header: Text("Soon")) {
                            ForEach(categorizedProducts.soon) { product in
                                productRow(product)
                            }
                        }
                    }
                }
                .navigationTitle("Shopping")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            markAllPurchased()
                        } label: {
                            Label("Mark all", systemImage: "checkmark.circle")
                        }
                    }
                }
            }
        }
    }
    
    private func categorizeProducts() -> (overdue: [Product], today: [Product], tomorrow: [Product], soon: [Product]) {
        let now = Calendar.current.startOfDay(for: .now)
        var overdue: [Product] = []
        var today: [Product] = []
        var tomorrow: [Product] = []
        var soon: [Product] = []
        
        for product in dueSoon {
            let days = Calendar.current.dateComponents([.day], from: now, to: product.nextRunOutDate).day ?? 0
            if days < 0 {
                overdue.append(product)
            } else if days == 0 {
                today.append(product)
            } else if days == 1 {
                tomorrow.append(product)
            } else {
                soon.append(product)
            }
        }
        
        // Sort each group by category, then by name
        let sortByCategory: (Product, Product) -> Bool = { a, b in
            if a.category.rawValue != b.category.rawValue {
                return a.category.rawValue < b.category.rawValue
            }
            return a.name < b.name
        }
        
        return (
            overdue.sorted(by: sortByCategory),
            today.sorted(by: sortByCategory),
            tomorrow.sorted(by: sortByCategory),
            soon.sorted(by: sortByCategory)
        )
    }
    
    private func productRow(_ product: Product) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: product.category.systemImage)
                    .foregroundStyle(.secondary)
                    .frame(width: 16)
                Text(product.name)
            }
            Spacer()
            Text(formattedDate(product.nextRunOutDate))
                .foregroundStyle(Color.secondary)
        }
        .swipeActions(edge: .trailing) {
            Button {
                markPurchased(product)
            } label: {
                Label("Purchased", systemImage: "checkmark")
            }
            .tint(.green)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        return f.string(from: date)
    }

    private func formattedCurrency(_ value: Double) -> String {
        let n = NSNumber(value: value)
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currencyCode
        return f.string(from: n) ?? "—"
    }

    private func markPurchased(_ product: Product) {
        product.lastPurchasedAt = .now
        try? context.save()
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    private func markAllPurchased() {
        for product in dueSoon {
            product.lastPurchasedAt = .now
        }
        try? context.save()
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }
}