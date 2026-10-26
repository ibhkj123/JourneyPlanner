import WidgetKit
import SwiftUI
import AppIntents

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: .now,
            configuration: ConfigurationAppIntent(),
            journey: SharedJourney(
                name: "Weekend Getaway",
                destination: "Sydney",
                departureDate: .now
            )
        )
    }

    func snapshot(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) async -> SimpleEntry {
        makeEntry(configuration: configuration)
    }

    func timeline(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) async -> Timeline<SimpleEntry> {
        let entry = makeEntry(configuration: configuration)

        return Timeline(
            entries: [entry],
            policy: .after(Date().addingTimeInterval(900))
        )
    }

    private func makeEntry(
        configuration: ConfigurationAppIntent
    ) -> SimpleEntry {
        let journeys = SharedJourneyStore.load()

        let nextJourney = journeys
            .filter { $0.departureDate >= Calendar.current.startOfDay(for: .now) }
            .sorted { $0.departureDate < $1.departureDate }
            .first

        return SimpleEntry(
            date: .now,
            configuration: configuration,
            journey: nextJourney ?? journeys.sorted {
                $0.departureDate < $1.departureDate
            }.first
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let journey: SharedJourney?
}


struct JourneyPlannerWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "airplane")
                    .foregroundStyle(.blue)

                Text("Journey Planner")
                    .font(.headline)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            if let journey = entry.journey {
                Text(journey.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                Label(journey.destination, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(
                    journey.departureDate,
                    format: .dateTime.month(.abbreviated).day()
                )
                .font(.caption)
            } else {
                Text("No trips yet")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Create a journey in the app to see it here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}


struct JourneyPlannerWidget: Widget {
    let kind: String = "JourneyPlannerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            JourneyPlannerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    JourneyPlannerWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: ConfigurationAppIntent(),
        journey: SharedJourney(
            name: "Weekend Getaway",
            destination: "Sydney",
            departureDate: .now
        )
    )
}
