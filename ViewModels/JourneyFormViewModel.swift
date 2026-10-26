
import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class JourneyFormViewModel {
    var name = ""
    var destination = ""
    var departureDate = Date()
    var returnDate = Calendar.current.date(
        byAdding: .day,
        value: 2,
        to: Date()
    ) ?? Date()
    var notes = ""
    var errorMessage: String?

    func save(context: ModelContext) -> Bool {
        do {
            let repository = SwiftDataJourneyRepository(context: context)

            try CreateJourneyUseCase(repository: repository).execute(
                name: name,
                destination: destination,
                departureDate: departureDate,
                returnDate: returnDate,
                notes: notes
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
