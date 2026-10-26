import Foundation

@MainActor
struct CreateJourneyUseCase {
    private let repository: any JourneyRepositoryProtocol

    init(repository: any JourneyRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        name: String,
        destination: String,
        departureDate: Date,
        returnDate: Date,
        notes: String
    ) throws -> Journey {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDestination = destination.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw JourneyError.emptyName
        }

        guard !trimmedDestination.isEmpty else {
            throw JourneyError.emptyDestination
        }

        guard returnDate >= departureDate else {
            throw JourneyError.invalidDates
        }

        let journey = Journey(
            name: trimmedName,
            destination: trimmedDestination,
            departureDate: departureDate,
            returnDate: returnDate,
            notes: notes
        )

        try repository.insert(journey)
        return journey
    }
}
