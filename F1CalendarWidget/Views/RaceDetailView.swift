import SwiftUI

struct RaceDetailView: View {
    let race: Race
    @StateObject private var settings = SettingsManager.shared

    @State private var weatherState: WeatherLoadState = .noApiKey
    @State private var raceResults: [DriverResult] = []

    private var circuitInfo: CircuitInfo? {
        CircuitDatabase.info(for: race.shortName)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    RaceHeaderView(race: race)

                    // Divider
                    Rectangle()
                        .fill(Color.f1Divider)
                        .frame(height: 1)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                    
                    // Session rows
                    VStack(spacing: 0) {
                        ForEach(Array(race.sessions.enumerated()), id: \.offset) { _, session in
                            AppSessionRowView(session: session)
                        }
                    }

                    // Race results (when completed)
                    if race.isCompleted && !raceResults.isEmpty {
                        Rectangle()
                            .fill(Color.f1Divider)
                            .frame(height: 1)

                        RaceResultsView(results: raceResults)
                    }

                    // Divider
                    Rectangle()
                        .fill(Color.f1Divider)
                        .frame(height: 1)
                        .padding(.top, 10)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)

                    // Weather
                    WeatherSectionView(state: weatherState, temperatureUnit: settings.temperatureUnit)
                        .padding(.vertical, 16)

                    // Circuit info
                    if let info = circuitInfo {
                        CircuitInfoView(circuit: info)
                            .padding(.bottom, 24)
                    }
                }
            }
            .background(Color("f1Background"))
            .task {
                await loadWeather()
                await loadResults()
            }
        }
    }

    // MARK: - Weather Loading

    private func loadWeather() async {
        guard !settings.weatherApiKey.isEmpty else {
            weatherState = .noApiKey
            return
        }
        guard let info = circuitInfo else {
            weatherState = .error
            return
        }

        weatherState = .loading
        let forecasts = await WeatherService.shared.fetchForecast(
            latitude: info.latitude,
            longitude: info.longitude,
            apiKey: settings.weatherApiKey
        )

        if !forecasts.isEmpty {
            weatherState = .loaded(forecasts)
        } else {
            weatherState = .error
        }
    }

    // MARK: - Results Loading

    private func loadResults() async {
        guard race.isCompleted else { return }
        // Find the race session key from API sessions
        if let raceSession = race.apiSessions?.last {
            // Use session name hash as a placeholder session key
            // In production, session_key comes from the API
            let sessionKey = raceSession.name.hashValue
            raceResults = await F1APIService.shared.fetchResults(for: sessionKey)
        }
    }
}

// MARK: - Previews

#Preview {
    RaceDetailView(race: F1Calendar.fallbackRaces[2]) // Japan
        .preferredColorScheme(.dark)
}

#Preview("Live") {
    RaceDetailView(race: .previewLive)
        .preferredColorScheme(.dark)
}
