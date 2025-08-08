import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @Query(sort: \Product.nextRunOutDate) private var products: [Product]

    var dueSoon: [Product] {
        let now = Calendar.current.startOfDay(for: .now)
        return products.filter { product in
            let days = Calendar.current.dateComponents([.day], from: now, to: product.nextRunOutDate).day ?? 0
            return days <= 2
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if dueSoon.isEmpty {
                    ContentUnavailableView("All set", systemImage: "checkmark.seal", description: Text("Nothing due in the next 2 days"))
                } else {
                    ForEach(dueSoon) { product in
                        HStack {
                            Text(product.name)
                            Spacer()
                            Text(formattedDate(product.nextRunOutDate))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Shopping")
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        return f.string(from: date)
    }
}


