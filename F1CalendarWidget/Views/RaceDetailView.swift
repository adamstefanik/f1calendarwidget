import SwiftUI

struct RaceDetailView: View {
    let race: Race
    var canGoBack: Bool = false
    var canGoForward: Bool = false
    var onBack: (() -> Void)? = nil
    var onForward: (() -> Void)? = nil
    var onRefresh: (() async -> Void)? = nil

    @StateObject private var settings = SettingsManager.shared

    @State private var weatherState: WeatherLoadState = .loading
    @State private var raceResults: [DriverResult] = []

    private var circuitInfo: CircuitInfo? {
        CircuitDatabase.info(for: race.shortName)
    }

    private var isWeatherAvailable: Bool {
        guard !race.isCompleted else { return false }
        let daysUntilRace = race.weekendStart.timeIntervalSinceNow / 86400
        return daysUntilRace <= 5
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Navigation arrows + Header (swipeable)
                    VStack(spacing: 0) {
                        if canGoBack || canGoForward {
                            ZStack {
                                Text("RACE \(race.round)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.f1SecondaryText)

                                HStack {
                                    Button { onBack?() } label: {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(canGoBack ? .white : .f1SecondaryText.opacity(0.3))
                                            .frame(width: 32, height: 32)
                                            .background(Circle().fill(Color("f1Surface")))
                                            .overlay(Circle().stroke(Color.f1Border, lineWidth: 1))
                                    }
                                    .disabled(!canGoBack)

                                    Spacer()

                                    Button { onForward?() } label: {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(canGoForward ? .white : .f1SecondaryText.opacity(0.3))
                                            .frame(width: 32, height: 32)
                                            .background(Circle().fill(Color("f1Surface")))
                                            .overlay(Circle().stroke(Color.f1Border, lineWidth: 1))
                                    }
                                    .disabled(!canGoForward)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        }

                        RaceHeaderView(race: race)
                    }

                    // Divider
                    Rectangle()
                        .fill(Color.f1Divider)
                        .frame(height: 1)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .padding(.leading, 34)
                        .padding(.trailing, 34)
                    
                    // Session rows
                    VStack(spacing: 0) {
                        ForEach(Array(race.sessions.enumerated()), id: \.offset) { _, session in
                            AppSessionRowView(session: session, isCanceled: race.isCanceled)
                        }
                    }

                    // Race results (when completed)
                    if race.isCompleted && !raceResults.isEmpty {
                        Rectangle()
                            .fill(Color.f1Divider)
                            .frame(height: 1)
                            .padding(.top, 10)
                            .padding(.leading, 34)
                            .padding(.trailing, 34)

                        RaceResultsView(results: raceResults)
                    }

                    // Divider before weather
                    if isWeatherAvailable {
                        Rectangle()
                            .fill(Color.f1Divider)
                            .frame(height: 1)
                            .padding(.top, 4)
                            .padding(.leading, 34)
                            .padding(.trailing, 34)
                    }

                    // Weather (only available within 5 days of race weekend)
                    if isWeatherAvailable {
                        WeatherSectionView(state: weatherState, temperatureUnit: settings.temperatureUnit)
                            .padding(.top, 20)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }

                    // Divider before circuit
                    if circuitInfo != nil {
                        Rectangle()
                            .fill(Color.f1Divider)
                            .frame(height: 1)
                            .padding(.top, 10)
                            .padding(.leading, 34)
                            .padding(.trailing, 34)
                    }

                    // Circuit info
                    if let info = circuitInfo {
                        CircuitInfoView(circuit: info, raceName: race.name)
                            .padding(.top, 20)
                            .padding(.bottom, 24)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }
                }
            }
            .background(Color("f1Background"))
            .tint(.f1Red)
            .simultaneousGesture(
                DragGesture(minimumDistance: 50, coordinateSpace: .global)
                    .onEnded { value in
                        let screenWidth = UIScreen.main.bounds.width
                        let startX = value.startLocation.x
                        let horizontal = value.translation.width
                        guard abs(horizontal) > abs(value.translation.height) else { return }

                        // Only trigger from left/right 1/5 edge
                        if startX < screenWidth / 5 && horizontal > 50 && canGoBack {
                            onBack?()
                        } else if startX > screenWidth * 4 / 5 && horizontal < -50 && canGoForward {
                            onForward?()
                        }
                    }
            )
            .refreshable {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                await onRefresh?()
                weatherState = .loading
                raceResults = []
                await loadWeather()
                await loadResults()
            }
            .task(id: race.id) {
                weatherState = .loading
                raceResults = []
                await loadWeather()
                await loadResults()
            }
        }
    }

    // MARK: - Weather Loading

    private func loadWeather() async {
        guard isWeatherAvailable, let info = circuitInfo else {
            weatherState = .error
            return
        }

        weatherState = .loading
        let forecasts = await WeatherService.shared.fetchForecast(
            latitude: info.latitude,
            longitude: info.longitude,
            weekendStart: race.weekendStart,
            raceDate: race.raceDate
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
        // Find the race (GRAND PRIX) session with a real API session key
        let raceSession = race.sessions.last { $0.name == "GRAND PRIX" && $0.sessionKey != nil }
            ?? race.sessions.last { $0.sessionKey != nil }
        guard let key = raceSession?.sessionKey else { return }
        raceResults = await F1APIService.shared.fetchResults(for: key)
    }
}

