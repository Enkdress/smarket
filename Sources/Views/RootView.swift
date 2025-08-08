import SwiftUI
import SwiftData

struct RootView: View {
    var body: some View {
        TabView {
            ProductsListView()
                .tabItem { Label("Products", systemImage: "cart") }

            ShoppingListView()
                .tabItem { Label("Shopping", systemImage: "list.bullet") }

            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .modelContainer(for: [Product.self, AppSettings.self], inMemory: true)
    }
}


