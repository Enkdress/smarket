import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct ProductsListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Product.name) private var products: [Product]
    @Query private var settings: [AppSettings]
    @State private var showingAdd = false
    @State private var editingProduct: Product? = nil
    @State private var searchText: String = ""
    @State private var selectedFilter: ProductFilter = .all
    @State private var selectedCategory: ProductCategory? = nil

    var body: some View {
        NavigationStack {
            List {
                if filteredProducts.isEmpty {
                    ContentUnavailableView("No products", systemImage: "cart", description: Text("Add your first product to get started"))
                } else {
                    ForEach(filteredProducts) { product in
                        NavigationLink(value: product.id) {
                            ProductRow(product: product, currencyCode: settings.first?.currency.rawValue ?? "COP", headsUpDays: settings.first?.headsUpDays ?? 2)
                        }
                        .swipeActions(edge: .leading) {
                            Button { logToday(product) } label: { Label("Log today", systemImage: "checkmark.circle") }
                                .tint(.green)
                            Button { editingProduct = product } label: { Label("Edit", systemImage: "pencil") }
                                .tint(.blue)
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("All Categories") {
                            selectedCategory = nil
                        }
                        Divider()
                        ForEach(ProductCategory.allCases) { category in
                            Button {
                                selectedCategory = selectedCategory == category ? nil : category
                            } label: {
                                HStack {
                                    Image(systemName: category.systemImage)
                                    Text(category.rawValue)
                                    if selectedCategory == category {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: selectedCategory?.systemImage ?? "line.3.horizontal.decrease.circle")
                            if let selectedCategory = selectedCategory {
                                Text(selectedCategory.rawValue)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAdd = true }) { Image(systemName: "plus") }
                }
                
                ToolbarItem(placement: .principal) {
                    Picker("Filter", selection: $selectedFilter) {
                        Text("All").tag(ProductFilter.all)
                        Text("Due soon").tag(ProductFilter.dueSoon)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditProductView()
            }
            .sheet(item: $editingProduct) { product in
                AddEditProductView(productToEdit: product)
            }
            .navigationDestination(for: UUID.self) { id in
                if let product = products.first(where: { $0.id == id }) {
                    ProductDetailView(product: product)
                }
            }
            .searchable(text: $searchText)
        }
    }

    private var filteredProducts: [Product] {
        let headsUp = settings.first?.headsUpDays ?? 2
        var base = products.filter { product in
            // Search filter
            if !searchText.isEmpty && !product.name.localizedCaseInsensitiveContains(searchText) {
                return false
            }
            
            // Category filter
            if let selectedCategory = selectedCategory, product.category != selectedCategory {
                return false
            }
            
            return true
        }
        
        // Date filter
        switch selectedFilter {
        case .all:
            return base
        case .dueSoon:
            let now = Calendar.current.startOfDay(for: .now)
            return base.filter { product in
                let days = Calendar.current.dateComponents([.day], from: now, to: product.nextRunOutDate).day ?? 0
                return days <= headsUp
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let product = filteredProducts[index]
            context.delete(product)
        }
        try? context.save()
    }

    private func logToday(_ product: Product) {
        product.lastPurchasedAt = .now
        try? context.save()
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }
}

private enum ProductFilter: Hashable { case all, dueSoon }

private struct ProductRow: View {
    let product: Product
    let currencyCode: String
    let headsUpDays: Int

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: product.category.systemImage)
                    .foregroundStyle(.secondary)
                    .frame(width: 16)
                
                VStack(alignment: .leading) {
                    Text(product.name)
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(secondaryLine)
                        Text("Monthly: \(formatCurrency(product.monthlyCostEstimate))")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            Spacer()
            BadgeView(product: product, headsUpDays: headsUpDays)
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let number = NSNumber(value: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: number) ?? "—"
    }

    private var secondaryLine: String {
        let now = Calendar.current.startOfDay(for: .now)
        let days = Calendar.current.dateComponents([.day], from: now, to: product.nextRunOutDate).day ?? 0
        if days < 0 { return "Overdue" }
        if days == 0 { return "Due today" }
        if days == 1 { return "Due tomorrow" }
        return "In \(days) days"
    }
}

private struct BadgeView: View {
    let product: Product
    let headsUpDays: Int
    var body: some View {
        let days = Calendar.current.dateComponents([.day], from: .now, to: product.nextRunOutDate).day ?? 0
        if days <= 0 {
            Text("Due")
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.red.opacity(0.15))
                .foregroundStyle(.red)
                .clipShape(Capsule())
        } else if days <= headsUpDays {
            Text("Soon")
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.orange.opacity(0.15))
                .foregroundStyle(.orange)
                .clipShape(Capsule())
        }
    }
}


