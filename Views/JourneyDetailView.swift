import SwiftUI
import SwiftData

struct JourneyDetailView: View {
    let journey: Journey

    private var shareText: String {
        """
        Journey: \(journey.name)
        Destination: \(journey.destination)
        Departure: \(journey.departureDate.formatted(date: .long, time: .omitted))
        Return: \(journey.returnDate.formatted(date: .long, time: .omitted))
        Notes: \(journey.notes.isEmpty ? "No notes added." : journey.notes)
        """
    }

    var body: some View {
        List {
            Section("Journey Details") {
                LabeledContent("Name", value: journey.name)
                LabeledContent("Destination", value: journey.destination)

                LabeledContent(
                    "Departure",
                    value: journey.departureDate.formatted(
                        date: .long,
                        time: .omitted
                    )
                )

                LabeledContent(
                    "Return",
                    value: journey.returnDate.formatted(
                        date: .long,
                        time: .omitted
                    )
                )
            }

            Section("Notes") {
                Text(
                    journey.notes.isEmpty
                        ? "No notes added."
                        : journey.notes
                )
                .foregroundStyle(
                    journey.notes.isEmpty ? .secondary : .primary
                )
            }

            Section("Activities") {
                NavigationLink {
                    JourneyActivitiesView(journeyID: journey.id)
                } label: {
                    Label(
                        "View Activities",
                        systemImage: "calendar"
                    )
                }
            }
        }
        .navigationTitle(journey.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share journey")
            }
        }
    }
}
