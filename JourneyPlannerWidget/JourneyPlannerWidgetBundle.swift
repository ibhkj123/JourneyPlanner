//
//  JourneyPlannerWidgetBundle.swift
//  JourneyPlannerWidget
//
//  Created by Zhenyu Xing on 23/10/2026.
//

import WidgetKit
import SwiftUI

@main
struct JourneyPlannerWidgetBundle: WidgetBundle {
    var body: some Widget {
        JourneyPlannerWidget()
        JourneyPlannerWidgetControl()
        JourneyPlannerWidgetLiveActivity()
    }
}
