import WidgetKit
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \Journey.departureDate)
    private var journeys: [Journey]

    @State private var viewModel = JourneyListViewModel()
    @State private var showingAddJourney = false

    private var filteredJourneys: [Journey] {
        viewModel.filter(journeys)
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredJourneys.isEmpty {
                    ContentUnavailableView {
                        Label(
                            viewModel.searchText.isEmpty
                                ? "No Journeys Yet"
                                : "No Results",
                            systemImage: "airplane"
                        )
                    } description: {
                        Text(
                            viewModel.searchText.isEmpty
                                ? "Start planning your next adventure."
                                : "Try another journey name or destination."
                        )
                    } actions: {
                        if viewModel.searchText.isEmpty {
                            Button("Plan a Journey") {
                                showingAddJourney = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } else {
                    List {
                        Section("YOUR JOURNEYS") {
                            ForEach(filteredJourneys) { journey in
                                NavigationLink {
                                    JourneyDetailView(journey: journey)
                                } label: {
                                    JourneyCard(journey: journey)
                                }
                            }
                            .onDelete(perform: deleteJourneys)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Journey Planner")
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search journeys"
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddJourney = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .accessibilityLabel("Add journey")
                }

                ToolbarItem(placement: .topBarLeading) {
                    if !journeys.isEmpty {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingAddJourney) {
                JourneyFormView()
            }
        }
    }

    private func deleteJourneys(at offsets: IndexSet) {
        let selectedJourneys = offsets.map {
            filteredJourneys[$0]
        }

        do {
            let repository = SwiftDataJourneyRepository(
                context: context
            )

            for journey in selectedJourneys {
                try repository.delete(journey)
            }

            let descriptor = FetchDescriptor<Journey>(
                sortBy: [SortDescriptor(\.departureDate)]
            )

            let remainingJourneys = try context.fetch(descriptor)

            let sharedJourneys = remainingJourneys.map { journey in
                SharedJourney(
                    name: journey.name,
                    destination: journey.destination,
                    departureDate: journey.departureDate
                )
            }

            SharedJourneyStore.save(sharedJourneys)

            WidgetCenter.shared.reloadAllTimelines()

        } catch {
            print("Delete journey failed: \(error.localizedDescription)")
        }
    }
}

struct JourneyCard: View {
    let journey: Journey

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "airplane")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 14)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(journey.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Label(
                    journey.destination,
                    systemImage: "mappin.and.ellipse"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Text(
                    "\(journey.departureDate.formatted(date: .abbreviated, time: .omitted)) – \(journey.returnDate.formatted(date: .abbreviated, time: .omitted))"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}
