import SwiftUI
import SwiftData

@main
struct SmarketApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .withAppLifecycle()
        }
        .modelContainer(for: [Product.self, AppSettings.self])
    }
}


