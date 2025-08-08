import SwiftUI
import SwiftData

struct AppLifecycleViewModifier: ViewModifier {
    @Environment(\.modelContext) private var context
    @Query private var settings: [AppSettings]
    @Query private var products: [Product]

    func body(content: Content) -> some View {
        content
            .task {
                await NotificationService.requestAuthorization()
                BackgroundRefreshScheduler.register()
                BackgroundRefreshScheduler.schedule()
                await rescheduleNotifications()
                ensureSettingsExists()
                await maybeSendBudgetAlert()
                PreviewSeed.seedIfEmpty(context)
            }
            .onChange(of: products) { _, _ in
                Task {
                    await rescheduleNotifications()
                    await maybeSendBudgetAlert()
                }
            }
            .onChange(of: settings.first?.reminderHour ?? 9) { _, _ in
                Task { await rescheduleNotifications() }
            }
    }

    private func ensureSettingsExists() {
        if settings.first == nil {
            let s = AppSettings()
            context.insert(s)
            try? context.save()
        }
    }

    private func rescheduleNotifications() async {
        let s = settings.first ?? AppSettings()
        await NotificationService.scheduleHeadsUpNotifications(
            for: products,
            headsUpDays: s.headsUpDays,
            reminderHour: s.reminderHour,
            currencyCode: s.currency.rawValue
        )
    }

    private func maybeSendBudgetAlert() async {
        let s = settings.first ?? AppSettings()
        let total = products.reduce(0.0) { $0 + $1.monthlyCostEstimate }
        await NotificationService.scheduleBudgetAlertIfNeeded(totalMonthly: total, settings: s)
        try? context.save()
    }
}

extension View {
    func withAppLifecycle() -> some View { modifier(AppLifecycleViewModifier()) }
}


