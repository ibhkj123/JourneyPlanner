
import Foundation
import SwiftData

@Model
final class Journey {
    var id: UUID
    var name: String
    var destination: String
    var departureDate: Date
    var returnDate: Date
    var notes: String
    var createdAt: Date

    init(
        name: String,
        destination: String,
        departureDate: Date,
        returnDate: Date,
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.destination = destination
        self.departureDate = departureDate
        self.returnDate = returnDate
        self.notes = notes
        self.createdAt = Date()
    }
}

@Model
final class JourneyActivity {
    var id: UUID
    var journeyID: UUID
    var title: String
    var location: String
    var date: Date
    var notes: String

    init(
        journeyID: UUID,
        title: String,
        location: String,
        date: Date,
        notes: String = ""
    ) {
        self.id = UUID()
        self.journeyID = journeyID
        self.title = title
        self.location = location
        self.date = date
        self.notes = notes
    }
}
