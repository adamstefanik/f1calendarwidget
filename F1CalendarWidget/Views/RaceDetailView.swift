import SwiftUI

struct RaceDetailView: View {
    let race: Race
    @StateObject private var settings = SettingsManager.shared

    @State private var weatherState: WeatherLoadState = .noApiKey
    private var circuitInfo: CircuitInfo? {
        CircuitDatabase.info(for: race.shortName)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                RaceHeaderView(race: race)

                // Divider
                Rectangle()
                    .fill(Color.f1Divider)
                    .frame(height: 1)
                    .padding(.horizontal, 16)

                // Session rows
                VStack(spacing: 0) {
                    ForEach(Array(race.sessions.enumerated()), id: \.offset) { _, session in
                        AppSessionRowView(session: session)
                    }
                }
                .padding(.vertical, 8)

                // Divider
                Rectangle()
                    .fill(Color.f1Divider)
                    .frame(height: 1)
                    .padding(.horizontal, 16)

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
