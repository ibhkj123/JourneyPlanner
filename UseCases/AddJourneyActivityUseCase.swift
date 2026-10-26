import Foundation

@MainActor
struct AddJourneyActivityUseCase {
    private let repository: any JourneyRepositoryProtocol

    init(repository: any JourneyRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        journeyID: UUID,
        title: String,
        location: String,
        date: Date,
        notes: String
    ) throws -> JourneyActivity {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            throw JourneyError.emptyActivityTitle
        }

        guard try repository.journey(withID: journeyID) != nil else {
            throw JourneyError.journeyNotFound
        }

        let activity = JourneyActivity(
            journeyID: journeyID,
            title: trimmedTitle,
            location: location,
            date: date,
            notes: notes
        )

        try repository.insert(activity)
        return activity
    }
}
