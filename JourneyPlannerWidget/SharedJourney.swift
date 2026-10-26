import Foundation

struct SharedJourney: Codable {
    let name: String
    let destination: String
    let departureDate: Date
}

enum SharedJourneyStore {
    static let appGroupID = "group.com.journeyplanner.shared"
    static let fileName = "journeys.json"

    static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent(fileName)
    }

    static func save(_ journeys: [SharedJourney]) {
        guard let url = fileURL else { return }

        do {
            let data = try JSONEncoder().encode(journeys)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Failed to save shared journeys: \(error)")
        }
    }

    static func load() -> [SharedJourney] {
        guard let url = fileURL,
              let data = try? Data(contentsOf: url),
              let journeys = try? JSONDecoder().decode(
                [SharedJourney].self,
                from: data
              ) else {
            return []
        }

        return journeys
    }
}
