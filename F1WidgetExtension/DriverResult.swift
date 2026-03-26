import Foundation

struct DriverResult: Codable, Identifiable {
    var id: String { "\(position)_\(driverName)" }
    let position: Int
    let driverName: String
    let team: String
    let time: String          // "+0.5s" or "1:30.123" for P1, or "DNF"
    let points: Int
    let fastestLap: Bool
    let dnf: Bool
}

#if DEBUG
extension DriverResult {
    static let previewResults: [DriverResult] = [
        DriverResult(position: 1,  driverName: "Max Verstappen",    team: "Red Bull Racing",   time: "1:28:45.123", points: 25, fastestLap: false, dnf: false),
        DriverResult(position: 2,  driverName: "Lando Norris",      team: "McLaren",           time: "+3.241s",     points: 18, fastestLap: true,  dnf: false),
        DriverResult(position: 3,  driverName: "Charles Leclerc",   team: "Ferrari",           time: "+5.102s",     points: 15, fastestLap: false, dnf: false),
        DriverResult(position: 4,  driverName: "Oscar Piastri",     team: "McLaren",           time: "+8.445s",     points: 12, fastestLap: false, dnf: false),
        DriverResult(position: 5,  driverName: "Carlos Sainz",      team: "Williams",          time: "+12.331s",    points: 10, fastestLap: false, dnf: false),
        DriverResult(position: 6,  driverName: "Lewis Hamilton",    team: "Ferrari",           time: "+15.002s",    points: 8,  fastestLap: false, dnf: false),
        DriverResult(position: 7,  driverName: "George Russell",    team: "Mercedes",          time: "+18.774s",    points: 6,  fastestLap: false, dnf: false),
        DriverResult(position: 8,  driverName: "Fernando Alonso",   team: "Aston Martin",      time: "+22.109s",    points: 4,  fastestLap: false, dnf: false),
        DriverResult(position: 9,  driverName: "Pierre Gasly",      team: "Alpine",            time: "+25.667s",    points: 2,  fastestLap: false, dnf: false),
        DriverResult(position: 10, driverName: "Nico Hulkenberg",   team: "Sauber",            time: "+28.990s",    points: 1,  fastestLap: false, dnf: false),
        DriverResult(position: 11, driverName: "Yuki Tsunoda",      team: "RB",                time: "+32.101s",    points: 0,  fastestLap: false, dnf: false),
        DriverResult(position: 12, driverName: "Alexander Albon",   team: "Williams",          time: "+35.443s",    points: 0,  fastestLap: false, dnf: false),
        DriverResult(position: 13, driverName: "Lance Stroll",      team: "Aston Martin",      time: "+38.221s",    points: 0,  fastestLap: false, dnf: false),
        DriverResult(position: 14, driverName: "Kevin Magnussen",   team: "Haas",              time: "+41.009s",    points: 0,  fastestLap: false, dnf: false),
        DriverResult(position: 15, driverName: "Daniel Ricciardo",  team: "RB",                time: "+44.556s",    points: 0,  fastestLap: false, dnf: false),
        DriverResult(position: 16, driverName: "Valtteri Bottas",   team: "Sauber",            time: "+48.332s",    points: 0,  fastestLap: false, dnf: false),
        DriverResult(position: 17, driverName: "Esteban Ocon",      team: "Haas",              time: "+52.118s",    points: 0,  fastestLap: false, dnf: false),
        DriverResult(position: 18, driverName: "Logan Sargeant",    team: "Alpine",            time: "+55.004s",    points: 0,  fastestLap: false, dnf: false),
        DriverResult(position: 19, driverName: "Sergio Perez",      team: "Red Bull Racing",   time: "DNF",         points: 0,  fastestLap: false, dnf: true),
        DriverResult(position: 20, driverName: "Oliver Bearman",    team: "Mercedes",          time: "DNF",         points: 0,  fastestLap: false, dnf: true),
    ]
}
#endif
