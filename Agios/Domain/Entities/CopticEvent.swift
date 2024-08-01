//
//  CopticEvent.swift
//  Agios
//
//  Created by Nikola Veljanovski on 26.6.24.
//

import Foundation

struct CopticEvent: Codable {
    let date: String
    let occasionID: String
    let upcomingEvents: [UpcomingEvent]
    let widgetIcon: [WidgetIcon]
}

struct UpcomingEvent: Codable {
    let synaxarTitle: String
    let iconID: String
}

struct WidgetIcon: Codable {
    let name: String
    let iconID: String
}
