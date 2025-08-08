import SwiftUI
import SwiftData

struct AddEditProductView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name: String = ""
    @State private var price: String = ""
    @State private var lastsDays: Int = 1
    @State private var lastPurchasedAt: Date = .now
    @State private var notes: String = ""

    var productToEdit: Product?

    var body: some View {
        NavigationStack {
            Form {
                Section("Product") {
                    TextField("Name", text: $name)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    Stepper(value: $lastsDays, in: 1...365) { Text("Lasts \(lastsDays) day(s)") }
                    DatePicker("Last purchased", selection: $lastPurchasedAt, displayedComponents: .date)
                    TextField("Notes", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle(productToEdit == nil ? "Add Product" : "Edit Product")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel", action: { dismiss() }) }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: save).disabled(!isValid)
                }
            }
            .onAppear { populateIfNeeded() }
        }
    }

    private var isValid: Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard Decimal(string: price) ?? 0 > 0 else { return false }
        return lastsDays >= 1
    }

    private func populateIfNeeded() {
        guard let product = productToEdit else { return }
        name = product.name
        price = String(product.priceLatest)
        lastsDays = product.lastsDays
        lastPurchasedAt = product.lastPurchasedAt
        notes = product.notes ?? ""
    }

    private func save() {
        guard let priceDecimal = Double(price) else { return }
        if let product = productToEdit {
            product.name = name
            product.priceLatest = priceDecimal
            product.lastsDays = lastsDays
            product.lastPurchasedAt = lastPurchasedAt
            product.notes = notes.isEmpty ? nil : notes
        } else {
            let newProduct = Product(
                name: name,
                priceLatest: priceDecimal,
                lastsDays: lastsDays,
                lastPurchasedAt: lastPurchasedAt,
                notes: notes.isEmpty ? nil : notes
            )
            context.insert(newProduct)
        }
        try? context.save()
        dismiss()
    }
}


