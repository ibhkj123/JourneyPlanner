
import SwiftUI
import SwiftData

struct JourneyFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name = ""
    @State private var destination = ""
    @State private var departureDate = Date()
    @State private var returnDate = Calendar.current.date(
        byAdding: .day,
        value: 2,
        to: Date()
    ) ?? Date()
    @State private var notes = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Journey Information") {
                    TextField("Journey name", text: $name)
                    TextField("Destination", text: $destination)

                    DatePicker(
                        "Departure",
                        selection: $departureDate,
                        displayedComponents: .date
                    )

                    DatePicker(
                        "Return",
                        selection: $returnDate,
                        in: departureDate...,
                        displayedComponents: .date
                    )
                }

                Section("Notes") {
                    TextField(
                        "Travel notes (optional)",
                        text: $notes,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Plan a Journey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveJourney()
                    }
                    .disabled(
                        name.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty ||
                        destination.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
        }
    }

    private func saveJourney() {
        guard returnDate >= departureDate else {
            errorMessage = "Return date must be after departure."
            return
        }

        do {
            let repository = SwiftDataJourneyRepository(context: context)

            try CreateJourneyUseCase(repository: repository).execute(
                name: name,
                destination: destination,
                departureDate: departureDate,
                returnDate: returnDate,
                notes: notes
            )

            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
