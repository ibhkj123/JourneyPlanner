import Foundation
import SwiftData

enum JourneyError: LocalizedError {
    case emptyName
    case emptyDestination
    case invalidDates
    case emptyActivityTitle
    case journeyNotFound

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Please enter a journey name."
        case .emptyDestination:
            return "Please enter a destination."
        case .invalidDates:
            return "Return date cannot be before departure."
        case .emptyActivityTitle:
            return "Please enter an activity title."
        case .journeyNotFound:
            return "The selected journey could not be found."
        }
    }
}

@MainActor
protocol JourneyRepositoryProtocol {
    func insert(_ journey: Journey) throws
    func insert(_ activity: JourneyActivity) throws
    func journey(withID id: UUID) throws -> Journey?
    func fetchJourneys() throws -> [Journey]
    func save() throws
    func delete(_ journey: Journey) throws
    func delete(_ activity: JourneyActivity) throws
}

@MainActor
struct SwiftDataJourneyRepository: JourneyRepositoryProtocol {
    let context: ModelContext

    func insert(_ journey: Journey) throws {
        context.insert(journey)
        try context.save()
    }

    func insert(_ activity: JourneyActivity) throws {
        context.insert(activity)
        try context.save()
    }

    func journey(withID id: UUID) throws -> Journey? {
        let descriptor = FetchDescriptor<Journey>(
            predicate: #Predicate { journey in
                journey.id == id
            }
        )

        return try context.fetch(descriptor).first
    }

    func fetchJourneys() throws -> [Journey] {
        let descriptor = FetchDescriptor<Journey>(
            sortBy: [SortDescriptor(\.departureDate)]
        )

        return try context.fetch(descriptor)
    }

    func save() throws {
        try context.save()
    }

    func delete(_ journey: Journey) throws {
        context.delete(journey)
        try context.save()
    }

    func delete(_ activity: JourneyActivity) throws {
        context.delete(activity)
        try context.save()
    }
}
