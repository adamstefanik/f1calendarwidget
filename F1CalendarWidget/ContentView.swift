import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: Int
    @ObservedObject var raceStore: RaceStore

    @State private var currentRaceIndex: Int?

    private var raceIndex: Int {
        if let idx = currentRaceIndex { return idx }
        let nextIdx = raceStore.races.firstIndex { !$0.isCompleted }
        return nextIdx ?? 0
    }

    private var currentRace: Race {
        raceStore.races[raceIndex]
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            RaceDetailView(
                race: currentRace,
                canGoBack: raceIndex > 0,
                canGoForward: raceIndex < raceStore.races.count - 1,
                onBack: { withAnimation { currentRaceIndex = raceIndex - 1 } },
                onForward: { withAnimation { currentRaceIndex = raceIndex + 1 } },
                onRefresh: { await raceStore.loadRaces() }
            )
            .id(currentRace.id)
            .tabItem {
                Image(systemName: "flag.checkered")
                Text("Race")
            }
            .tag(0)

            CalendarView(raceStore: raceStore)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(1)

            SettingsView(raceStore: raceStore)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }
        .tint(Color.f1Red)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView(selectedTab: .constant(0), raceStore: RaceStore())
}
