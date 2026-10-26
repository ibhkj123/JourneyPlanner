
import SwiftUI
import SwiftData

struct JourneyActivitiesView: View {
    let journeyID: UUID

    @Environment(\.modelContext) private var context
    @Query private var allActivities: [JourneyActivity]

    @State private var showingAddActivity = false
    @State private var errorMessage: String?

    private var activities: [JourneyActivity] {
        allActivities
            .filter { $0.journeyID == journeyID }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        Group {
            if activities.isEmpty {
                ContentUnavailableView(
                    "No Activities Yet",
                    systemImage: "calendar",
                    description: Text(
                        "Add activities to organise your trip."
                    )
                )
            } else {
                List {
                    ForEach(activities) { activity in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(activity.title)
                                .font(.headline)

                            if !activity.location.isEmpty {
                                Label(
                                    activity.location,
                                    systemImage: "mappin"
                                )
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }

                            Text(
                                activity.date.formatted(
                                    date: .abbreviated,
                                    time: .shortened
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            if !activity.notes.isEmpty {
                                Text(activity.notes)
                                    .font(.body)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete(perform: deleteActivities)
                }
            }
        }
        .navigationTitle("Activities")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddActivity = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add activity")
            }

            ToolbarItem(placement: .topBarLeading) {
                if !activities.isEmpty {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showingAddActivity) {
            ActivityFormView(journeyID: journeyID)
        }
        .alert(
            "Unable to Delete Activity",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "Please try again.")
        }
    }

    private func deleteActivities(at offsets: IndexSet) {
        let selected = offsets.map { activities[$0] }

        for activity in selected {
            context.delete(activity)
        }

        do {
            try context.save()
        } catch {
            context.rollback()
            errorMessage = error.localizedDescription
        }
    }
}
