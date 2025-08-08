import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var settings: [AppSettings]

    var body: some View {
        let settings = ensureSettings()
        Form {
            Section("Currency") {
                Picker("Currency", selection: Binding(
                    get: { settings.currency },
                    set: { settings.currency = $0; try? context.save() }
                )) {
                    ForEach(Currency.allCases) { c in
                        Text(c.rawValue).tag(c)
                    }
                }
            }

            Section("Notifications") {
                Stepper(value: Binding(
                    get: { settings.reminderHour },
                    set: { settings.reminderHour = $0; try? context.save() }
                ), in: 6...21) {
                    Text("Reminder hour: \(settings.reminderHour):00")
                }
            }

            Section("Budget") {
                Toggle("Enable budget alert", isOn: Binding(
                    get: { settings.budgetEnabled },
                    set: { settings.budgetEnabled = $0; try? context.save() }
                ))

                HStack {
                    Text("Amount")
                    Spacer()
                    CurrencyAmountField(value: Binding(
                        get: { settings.budgetAmount },
                        set: { settings.budgetAmount = $0; try? context.save() }
                    ), currencyCode: settings.currency.rawValue)
                    .frame(width: 160)
                }
            }
        }
        .navigationTitle("Settings")
    }

    private func ensureSettings() -> AppSettings {
        if let existing = settings.first { return existing }
        let s = AppSettings()
        context.insert(s)
        try? context.save()
        return s
    }
}

private struct CurrencyAmountField: View {
    @State private var text: String = ""
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
            .onChange(of: text) { _, newValue in
                let clean = newValue.filter { "0123456789.,".contains($0) }.replacingOccurrences(of: ",", with: ".")
                if let d = Double(clean) {
                    value.wrappedValue = d
                }
            }
            .onChange(of: value.wrappedValue) { _, newValue in
                text = Self.format(newValue, code: currencyCode)
            }
    }

    static func format(_ d: Double, code: String) -> String {
        let n = NSNumber(value: d)
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = code
        return f.string(from: n) ?? "0"
    }
}


