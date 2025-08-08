import SwiftUI
import SwiftData

struct ProductDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var settings: [AppSettings]
    @State private var showingEdit = false
    @State private var priceInput: String = ""

    let product: Product

    var body: some View {
        Form {
            Section("Info") {
                LabeledContent("Last purchased", value: formatDate(product.lastPurchasedAt))
                LabeledContent("Lasts", value: "\(product.lastsDays) days")
                LabeledContent("Next run-out", value: formatDate(product.nextRunOutDate))
                if let notes = product.notes, !notes.isEmpty {
                    Text(notes)
                }
            }

            Section("Cost estimate") {
                LabeledContent("Latest price", value: formatCurrency(product.priceLatest))
                LabeledContent("Daily cost", value: formatCurrency(product.dailyCost))
                LabeledContent("Monthly estimate", value: formatCurrency(product.monthlyCostEstimate))
            }

            Section("Log purchase") {
                TextField("Price", text: $priceInput)
                    .keyboardType(.decimalPad)
                Button("Update to today") { logPurchase() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle(product.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { Button("Edit") { showingEdit = true } }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditProductView(productToEdit: product)
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let number = NSNumber(value: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = settings.first?.currency.rawValue ?? "COP"
        return formatter.string(from: number) ?? "—"
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }

    private func logPurchase() {
        if let price = Double(priceInput), price > 0 {
            product.priceLatest = price
        }
        product.lastPurchasedAt = .now
        try? context.save()
        priceInput = ""
    }
}


