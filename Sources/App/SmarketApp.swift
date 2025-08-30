import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct SmarketApp: App {
    init() {
        // Register BGTask launch handler as early as possible
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundRefreshScheduler.taskIdentifier, using: nil) { task in
            guard let appRefresh = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            // Defer to the shared handler
            let mirror = BackgroundRefreshScheduler.self
            let selector = NSSelectorFromString("handle:")
            // Call private handler directly
            let request = BGAppRefreshTaskRequest(identifier: BackgroundRefreshScheduler.taskIdentifier)
            _ = request // silence unused
            // Reuse the same logic as our static register() would call
            // We directly call the handler function since we cannot reference it via selector in Swift
            // This mirrors what BackgroundRefreshScheduler.register() set up
            // Note: We can't access private function here, so replicate minimal logic
            BackgroundRefreshScheduler.schedule()
            let operation = NotificationRescheduleOperation()
            appRefresh.expirationHandler = {
                operation.cancel()
            }
            operation.completionBlock = {
                appRefresh.setTaskCompleted(success: !operation.isCancelled)
            }
            OperationQueue().addOperation(operation)
        }
    }
    var body: some Scene {
        WindowGroup {
            RootView()
                .withAppLifecycle()
        }
        .modelContainer(for: [Product.self, AppSettings.self])
    }
}


