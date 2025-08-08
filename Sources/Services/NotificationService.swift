import Foundation
import UserNotifications

enum NotificationService {
    static func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    static func scheduleHeadsUpNotifications(for products: [Product], headsUpDays: Int, reminderHour: Int, currencyCode: String) async {
        let center = UNUserNotificationCenter.current()
        await center.removeAllPendingNotificationRequests()

        let calendar = Calendar.current
        let now = Date()

        for product in products {
            let runOut = product.nextRunOutDate
            guard let fireDate = calendar.date(byAdding: .day, value: -headsUpDays, to: runOut) else { continue }
            guard fireDate > now else { continue }

            var dateComponents = calendar.dateComponents([.year, .month, .day], from: fireDate)
            dateComponents.hour = reminderHour
            dateComponents.minute = 0

            let content = UNMutableNotificationContent()
            content.title = "Restock: \(product.name)"
            let price = formatCurrency(product.priceLatest, code: currencyCode)
            content.body = "Expected to run out soon. Latest price: \(price)."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: product.id.uuidString, content: content, trigger: trigger)
            await center.add(request)
        }
    }

    private static func formatCurrency(_ value: Double, code: String) -> String {
        let number = NSNumber(value: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.string(from: number) ?? "—"
    }

    static func scheduleBudgetAlertIfNeeded(totalMonthly: Double, settings: AppSettings) async {
        guard settings.budgetEnabled, totalMonthly >= settings.budgetAmount else { return }

        // Avoid spamming: alert once per day
        let calendar = Calendar.current
        if let last = settings.lastBudgetAlertAt, calendar.isDateInToday(last) { return }

        let content = UNMutableNotificationContent()
        content.title = "Budget alert"
        let amount = formatCurrency(settings.budgetAmount, code: settings.currency.rawValue)
        let total = formatCurrency(totalMonthly, code: settings.currency.rawValue)
        content.body = "Estimated monthly spend (\(total)) meets/exceeds your budget (\(amount))."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "budget-alert", content: content, trigger: trigger)
        await UNUserNotificationCenter.current().add(request)

        settings.lastBudgetAlertAt = Date()
    }
}


