import SwiftUI
import Combine
import WidgetKit

@main
struct F1CalendarWidgetApp: App {
    @State private var selectedTab = 0
    @StateObject private var raceStore = RaceStore()

    var body: some Scene {
        WindowGroup {
            ContentView(selectedTab: $selectedTab, raceStore: raceStore)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                .task {
                    await raceStore.loadRaces()
                    await scheduleNotificationsIfAllowed()
                    WidgetCenter.shared.reloadAllTimelines()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    Task {
                        await raceStore.loadRaces()
                        await scheduleNotificationsIfAllowed()
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "f1calendar" else { return }
        selectedTab = 0
    }

    private func scheduleNotificationsIfAllowed() async {
        let granted = await NotificationManager.shared.requestPermission()
        if granted {
            NotificationManager.shared.scheduleNotifications(
                for: raceStore.races,
                settings: SettingsManager.shared
            )
        }
    }
}

// MARK: - Race Store

final class RaceStore: ObservableObject {
    @Published var races: [Race] = F1Calendar.fallbackRaces
    @Published var isLoading = true
    var nextRace: Race? { races.first { !$0.isCompleted } }

    @MainActor
    func loadRaces() async {
        let apiRaces = await F1APIService.shared.fetchRaces()
        if !apiRaces.isEmpty {
            races = apiRaces
            F1Calendar.cachedRaces = apiRaces
        }
        isLoading = false
    }
}
