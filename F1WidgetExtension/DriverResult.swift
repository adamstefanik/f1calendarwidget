import Foundation

struct DriverResult: Codable, Identifiable {
    var id: Int { position }
    let position: Int
    let driverName: String
    let team: String
    let time: String          // "+0.5s" or "1:30.123" for P1, or "DNF"
    let points: Int
    let fastestLap: Bool
    let dnf: Bool
}
