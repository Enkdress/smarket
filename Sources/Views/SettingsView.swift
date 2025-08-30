import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var settings: [AppSettings]
    @Query private var products: [Product]

    var body: some View {
        let settings = ensureSettings()
        Form {
            Section(header: Text("Currency")) {
                Picker("Currency", selection: Binding(
                    get: { settings.currency },
                    set: { settings.currency = $0; try? context.save() }
                )) {
                    ForEach(Currency.allCases) { c in
                        Text(c.rawValue).tag(c)
                    }
                }
            }

            Section(header: Text("Notifications")) {
                Stepper(value: Binding(
                    get: { settings.reminderHour },
                    set: { settings.reminderHour = $0; try? context.save() }
                ), in: 6...21) {
                    Text("Reminder hour: \(settings.reminderHour):00")
                }
            }

            Section(header: Text("Budget")) {
                Toggle("Enable budget alert", isOn: Binding(
                    get: { settings.budgetEnabled },
                    set: { settings.budgetEnabled = $0; try? context.save() }
                ))

                HStack {
                    Text("Amount")
                    Spacer()
                    CurrencyAmountField(
                        value: Binding(
                            get: { settings.budgetAmount },
                            set: { settings.budgetAmount = $0 }
                        ), 
                        currencyCode: settings.currency.rawValue
                    )
                    .frame(width: 160)
                }
            }
            
            Section(header: Text("Smart categorization")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Products are automatically categorized based on their names using smart keyword detection.")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    
                    Button("Update all product categories") {
                        updateAllProductCategories()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .navigationTitle("Settings")
        .onDisappear {
            try? context.save()
        }

    }

    private func ensureSettings() -> AppSettings {
        if let existing = settings.first { return existing }
        let s = AppSettings()
        context.insert(s)
        try? context.save()
        return s
    }
    
    private func updateAllProductCategories() {
        for product in products {
            product.autoUpdateCategory()
        }
        try? context.save()
    }
}

private struct CurrencyAmountField: View {
    @Environment(\.modelContext) private var context
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    let value: Binding<Double>
    let currencyCode: String

    init(value: Binding<Double>, currencyCode: String) {
        self.value = value
        self.currencyCode = currencyCode
        _text = State(initialValue: Self.format(value.wrappedValue, code: currencyCode))
    }

    var body: some View {
        TextField("0", text: $text)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .submitLabel(.done)
            .onSubmit {
                commit()
            }
            .onChange(of: isFocused) { _, focused in
                if !focused { commit() }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isFocused = false
                    }
                }
            }
    }

    private func commit() {
        let clean = text.filter { "0123456789.,".contains($0) }.replacingOccurrences(of: ",", with: ".")
        if let d = Double(clean) {
            value.wrappedValue = d
        }
        try? context.save()
        text = Self.format(value.wrappedValue, code: currencyCode)
    }

    static func format(_ d: Double, code: String) -> String {
        let n = NSNumber(value: d)
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = code
        return f.string(from: n) ?? "0"
    }
}


