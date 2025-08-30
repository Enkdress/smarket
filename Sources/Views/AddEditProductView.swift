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
    @FocusState private var focusedField: Field?

    var productToEdit: Product?
    
    enum Field: Hashable {
        case name, price, notes
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Product") {
                    TextField("Name", text: $name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .price
                        }

                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .price)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .notes
                        }

                    
                    Stepper(value: $lastsDays, in: 1...365) { Text("Lasts \(lastsDays) day(s)") }
                    DatePicker("Last purchased", selection: $lastPurchasedAt, displayedComponents: .date)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .focused($focusedField, equals: .notes)
                        .submitLabel(.done)
                        .onSubmit {
                            focusedField = nil
                        }
                }
            }
            .navigationTitle(productToEdit == nil ? "Add Product" : "Edit Product")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel", action: { dismiss() }) }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: save).disabled(!isValid)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Button("Previous") {
                            switch focusedField {
                            case .price: focusedField = .name
                            case .notes: focusedField = .price
                            default: break
                            }
                        }
                        .disabled(focusedField == .name || focusedField == nil)
                        
                        Button("Next") {
                            switch focusedField {
                            case .name: focusedField = .price
                            case .price: focusedField = .notes
                            default: break
                            }
                        }
                        .disabled(focusedField == .notes || focusedField == nil)
                        
                        Spacer()
                        
                        Button("Done") {
                            focusedField = nil
                        }
                    }
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
        focusedField = nil // Dismiss keyboard first
        guard let priceDecimal = Double(price) else { return }
        // Auto-categorize based on product name
        let autoCategory = ProductCategory.categorize(productName: name)
        
        if let product = productToEdit {
            product.name = name
            product.priceLatest = priceDecimal
            product.lastsDays = lastsDays
            product.lastPurchasedAt = lastPurchasedAt
            product.notes = notes.isEmpty ? nil : notes
            product.category = autoCategory
        } else {
            let newProduct = Product(
                name: name,
                priceLatest: priceDecimal,
                lastsDays: lastsDays,
                lastPurchasedAt: lastPurchasedAt,
                notes: notes.isEmpty ? nil : notes,
                category: autoCategory
            )
            context.insert(newProduct)
        }
        try? context.save()
        dismiss()
    }
    

}


