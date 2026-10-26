//
//  JourneyPlannerWidgetLiveActivity.swift
//  JourneyPlannerWidget
//
//  Created by Zhenyu Xing on 23/10/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct JourneyPlannerWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct JourneyPlannerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: JourneyPlannerWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension JourneyPlannerWidgetAttributes {
    fileprivate static var preview: JourneyPlannerWidgetAttributes {
        JourneyPlannerWidgetAttributes(name: "World")
    }
}

extension JourneyPlannerWidgetAttributes.ContentState {
    fileprivate static var smiley: JourneyPlannerWidgetAttributes.ContentState {
        JourneyPlannerWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: JourneyPlannerWidgetAttributes.ContentState {
         JourneyPlannerWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: JourneyPlannerWidgetAttributes.preview) {
   JourneyPlannerWidgetLiveActivity()
} contentStates: {
    JourneyPlannerWidgetAttributes.ContentState.smiley
    JourneyPlannerWidgetAttributes.ContentState.starEyes
}
