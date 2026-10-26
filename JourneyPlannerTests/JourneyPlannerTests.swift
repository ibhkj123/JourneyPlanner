import XCTest
import SwiftData
@testable import JourneyPlanner

@MainActor
final class JourneyPlannerTests: XCTestCase {

    private func makeContext() throws -> ModelContext {
        let schema = Schema([
            Journey.self,
            JourneyActivity.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )

        return ModelContext(container)
    }

    func testCreateJourneySuccessfully() throws {
        let context = try makeContext()
        let repository = SwiftDataJourneyRepository(context: context)
        let useCase = CreateJourneyUseCase(repository: repository)

        try useCase.execute(
            name: "Sydney Weekend",
            destination: "Sydney",
            departureDate: Date(),
            returnDate: Calendar.current.date(
                byAdding: .day,
                value: 2,
                to: Date()
            )!,
            notes: "Visit the harbour"
        )

        let journeys = try context.fetch(
            FetchDescriptor<Journey>()
        )

        XCTAssertEqual(journeys.count, 1)
        XCTAssertEqual(journeys.first?.name, "Sydney Weekend")
        XCTAssertEqual(journeys.first?.destination, "Sydney")
    }

    func testRejectEmptyJourneyName() throws {
        let context = try makeContext()
        let repository = SwiftDataJourneyRepository(context: context)
        let useCase = CreateJourneyUseCase(repository: repository)

        XCTAssertThrowsError(
            try useCase.execute(
                name: "   ",
                destination: "Sydney",
                departureDate: Date(),
                returnDate: Date().addingTimeInterval(86400),
                notes: ""
            )
        )
    }

    func testRejectEmptyDestination() throws {
        let context = try makeContext()
        let repository = SwiftDataJourneyRepository(context: context)
        let useCase = CreateJourneyUseCase(repository: repository)

        XCTAssertThrowsError(
            try useCase.execute(
                name: "Weekend Trip",
                destination: " ",
                departureDate: Date(),
                returnDate: Date().addingTimeInterval(86400),
                notes: ""
            )
        )
    }

    func testRejectReturnDateBeforeDeparture() throws {
        let context = try makeContext()
        let repository = SwiftDataJourneyRepository(context: context)
        let useCase = CreateJourneyUseCase(repository: repository)

        let departure = Date()
        let returnDate = departure.addingTimeInterval(-86400)

        XCTAssertThrowsError(
            try useCase.execute(
                name: "Weekend Trip",
                destination: "Melbourne",
                departureDate: departure,
                returnDate: returnDate,
                notes: ""
            )
        )
    }

    func testRejectEmptyActivityTitle() throws {
        let context = try makeContext()

        let journey = Journey(
            name: "City Trip",
            destination: "Sydney",
            departureDate: Date(),
            returnDate: Date().addingTimeInterval(86400)
        )

        context.insert(journey)

        let repository = SwiftDataJourneyRepository(context: context)
        let useCase = AddJourneyActivityUseCase(repository: repository)

        XCTAssertThrowsError(
            try useCase.execute(
                journeyID: journey.id,
                title: " ",
                location: "Opera House",
                date: Date(),
                notes: ""
            )
        )
    }

    // MARK: - Mock Repository Tests

    func testMockCreatesJourney() throws {
        let repository = MockJourneyRepository()
        let useCase = CreateJourneyUseCase(repository: repository)

        let journey = try useCase.execute(
            name: "Weekend Trip",
            destination: "Melbourne",
            departureDate: Date(),
            returnDate: Date().addingTimeInterval(86400),
            notes: ""
        )

        XCTAssertEqual(repository.journeys.count, 1)
        XCTAssertEqual(journey.name, "Weekend Trip")
        XCTAssertEqual(journey.destination, "Melbourne")
    }

    func testMockRejectsEmptyName() {
        let repository = MockJourneyRepository()
        let useCase = CreateJourneyUseCase(repository: repository)

        XCTAssertThrowsError(
            try useCase.execute(
                name: " ",
                destination: "Sydney",
                departureDate: Date(),
                returnDate: Date().addingTimeInterval(86400),
                notes: ""
            )
        )

        XCTAssertTrue(repository.journeys.isEmpty)
    }

    func testMockRejectsEmptyDestination() {
        let repository = MockJourneyRepository()
        let useCase = CreateJourneyUseCase(repository: repository)

        XCTAssertThrowsError(
            try useCase.execute(
                name: "Weekend Trip",
                destination: " ",
                departureDate: Date(),
                returnDate: Date().addingTimeInterval(86400),
                notes: ""
            )
        )

        XCTAssertTrue(repository.journeys.isEmpty)
    }

    func testMockRejectsInvalidDates() {
        let repository = MockJourneyRepository()
        let useCase = CreateJourneyUseCase(repository: repository)

        let departure = Date()
        let returnDate = departure.addingTimeInterval(-86400)

        XCTAssertThrowsError(
            try useCase.execute(
                name: "Weekend Trip",
                destination: "Melbourne",
                departureDate: departure,
                returnDate: returnDate,
                notes: ""
            )
        )

        XCTAssertTrue(repository.journeys.isEmpty)
    }

    func testMockRejectsEmptyActivityTitle() throws {
        let repository = MockJourneyRepository()

        let journey = Journey(
            name: "City Trip",
            destination: "Sydney",
            departureDate: Date(),
            returnDate: Date().addingTimeInterval(86400)
        )

        repository.journeys.append(journey)

        let useCase = AddJourneyActivityUseCase(repository: repository)

        XCTAssertThrowsError(
            try useCase.execute(
                journeyID: journey.id,
                title: " ",
                location: "Opera House",
                date: Date(),
                notes: ""
            )
        )

        XCTAssertTrue(repository.activities.isEmpty)
    }

    func testMockRejectsActivityForMissingJourney() {
        let repository = MockJourneyRepository()
        let useCase = AddJourneyActivityUseCase(repository: repository)

        XCTAssertThrowsError(
            try useCase.execute(
                journeyID: UUID(),
                title: "Visit Museum",
                location: "Sydney",
                date: Date(),
                notes: ""
            )
        )

        XCTAssertTrue(repository.activities.isEmpty)
    }
}

// MARK: - Mock Repository

@MainActor
final class MockJourneyRepository: JourneyRepositoryProtocol {

    var journeys: [Journey] = []
    var activities: [JourneyActivity] = []

    func insert(_ journey: Journey) throws {
        journeys.append(journey)
    }

    func insert(_ activity: JourneyActivity) throws {
        activities.append(activity)
    }

    func journey(withID id: UUID) throws -> Journey? {
        journeys.first { $0.id == id }
    }

    func fetchJourneys() throws -> [Journey] {
        journeys
    }

    func save() throws {}

    func delete(_ journey: Journey) throws {
        journeys.removeAll { $0.id == journey.id }
    }

    func delete(_ activity: JourneyActivity) throws {
        activities.removeAll { $0.id == activity.id }
    }
}
