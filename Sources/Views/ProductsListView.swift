import SwiftUI
import SwiftData

struct ProductsListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Product.name) private var products: [Product]
    @Query private var settings: [AppSettings]
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(products) { product in
                    NavigationLink(value: product.id) {
                      ProductRow(product: product, currencyCode: settings.first?.currency.rawValue ?? "COP")
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAdd = true }) { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditProductView()
            }
            .navigationDestination(for: UUID.self) { id in
                if let product = products.first(where: { $0.id == id }) {
                    ProductDetailView(product: product)
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets { context.delete(products[index]) }
        try? context.save()
    }
}

private struct ProductRow: View {
    let product: Product
    let currencyCode: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.headline)
                Text("Monthly: \(formatCurrency(product.monthlyCostEstimate))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            BadgeView(product: product)
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let number = NSNumber(value: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: number) ?? "—"
    }
}

private struct BadgeView: View {
    let product: Product
    var body: some View {
        let days = Calendar.current.dateComponents([.day], from: .now, to: product.nextRunOutDate).day ?? 0
        if days <= 0 {
            Text("Due")
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.red.opacity(0.15))
                .foregroundStyle(.red)
                .clipShape(Capsule())
        } else if days <= 2 {
            Text("Soon")
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.orange.opacity(0.15))
                .foregroundStyle(.orange)
                .clipShape(Capsule())
        }
    }
}


