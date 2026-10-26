
import SwiftUI
import SwiftData

@main
struct JourneyPlannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Journey.self,
            JourneyActivity.self
        ])
    }
}
