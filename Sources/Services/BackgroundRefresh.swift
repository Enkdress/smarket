import Foundation
import BackgroundTasks
import SwiftData

enum BackgroundRefreshScheduler {
    static let taskIdentifier = "com.smarket.app.refresh"

    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            handle(task: task as! BGAppRefreshTask)
        }
    }

    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60 * 24) // ~daily
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func handle(task: BGAppRefreshTask) {
        schedule() // schedule next
        let operation = NotificationRescheduleOperation()
        task.expirationHandler = {
            operation.cancel()
        }
        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
        OperationQueue().addOperation(operation)
    }
}

final class NotificationRescheduleOperation: Operation {
    override func main() {
        guard !isCancelled else { return }

        let semaphore = DispatchSemaphore(value: 0)
        Task { @MainActor in
            do {
                let container = try ModelContainer(for: Product.self, AppSettings.self)
                let context = container.mainContext

                let products = try context.fetch(FetchDescriptor<Product>())
                let settings = (try? context.fetch(FetchDescriptor<AppSettings>()))?.first ?? AppSettings()

                await NotificationService.scheduleHeadsUpNotifications(
                    for: products,
                    headsUpDays: settings.headsUpDays,
                    reminderHour: settings.reminderHour,
                    currencyCode: settings.currency.rawValue
                )
            } catch {
                // Ignore background refresh errors
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
}


