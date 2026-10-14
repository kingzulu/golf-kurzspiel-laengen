import Foundation

/// Hält die Schläger und speichert jede Änderung sofort auf dem iPhone.
@MainActor
final class ClubStore: ObservableObject {
    @Published var clubs: [Club] {
        didSet { save() }
    }

    private static let storageKey = "kurzspiel-clubs-v1"

    static var defaultClubs: [Club] {
        ["LW", "SW", "GW", "PW", "9er"].map { Club(name: $0) }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let saved = try? JSONDecoder().decode([Club].self, from: data) {
            clubs = saved
        } else {
            clubs = Self.defaultClubs
        }
    }

    func addClub() -> Club.ID {
        let club = Club(name: "")
        clubs.append(club)
        return club.id
    }

    func delete(_ id: Club.ID) {
        clubs.removeAll { $0.id == id }
    }

    func reset() {
        clubs = Self.defaultClubs
    }

    private func save() {
        if let data = try? JSONEncoder().encode(clubs) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
