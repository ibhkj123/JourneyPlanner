
import Foundation
import Observation

@MainActor
@Observable
final class JourneyListViewModel {
    var searchText = ""

    func filter(_ journeys: [Journey]) -> [Journey] {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty else {
            return journeys
        }

        return journeys.filter { journey in
            journey.name.localizedCaseInsensitiveContains(query) ||
            journey.destination.localizedCaseInsensitiveContains(query)
        }
    }
}
