
import SwiftUI
import SwiftData

struct ActivityFormView: View {
    let journeyID: UUID

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var title = ""
    @State private var location = ""
    @State private var date = Date()
    @State private var notes = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Activity Information") {
                    TextField("Activity name", text: $title)
                    TextField("Location", text: $location)

                    DatePicker(
                        "Date and time",
                        selection: $date
                    )
                }

                Section("Notes") {
                    TextField(
                        "Activity notes (optional)",
                        text: $notes,
                        axis: .vertical
                    )
                    .lineLimit(3...5)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveActivity()
                    }
                    .disabled(
                        title.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
        }
    }

    private func saveActivity() {
        do {
            let repository = SwiftDataJourneyRepository(context: context)

            try AddJourneyActivityUseCase(
                repository: repository
            ).execute(
                journeyID: journeyID,
                title: title,
                location: location,
                date: date,
                notes: notes
            )

            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
