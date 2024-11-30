//
//  AgiosWidget.swift
//  AgiosWidget
//
//  Created by Nikola Veljanovski on 24.10.24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> DailyIconEntry {
        DailyIconEntry(date: Date(),
                       image: UIImage(named: "placeholder")!,
                       description: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyIconEntry) -> ()) {
        var snapshotIcon: UIImage
        var description: String
        if context.isPreview && !WidgetService.cachedIconAvailable {
            snapshotIcon = UIImage(named: "placeholder")!
        } else {
            snapshotIcon = WidgetService.cachedIcon!
        }
        if !WidgetService.cachedDescriptionAvailable {
            description = ""
        } else {
            description = WidgetService.cachedDescription!
        }
        let entry = DailyIconEntry(date: Date(),
                                   image: snapshotIcon,
                                   description: description)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyIconEntry>) -> Void) {
        Task {
            let defaults = UserDefaults(suiteName: "group.com.agios")
            let savedDateString = defaults?.string(forKey: "selectedDate") ?? WidgetService.date // fallback to today
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            // Parse savedDateString to Date
            let savedDate = dateFormatter.date(from: savedDateString) ?? Date()

            // Fetch data for the saved date
            let saint = try? await WidgetService.fetchSaint(for: savedDate)
            
            // Prepare the widget entry based on the fetched data
            let entry: DailyIconEntry
            if let saint = saint {
                // Display the icon if available
                entry = DailyIconEntry(date: savedDate, image: saint.image, description: saint.description)
            } else {
                // Show placeholder if no saint data is available
                entry = DailyIconEntry(date: savedDate, image: UIImage(named: "placeholder")!, description: "\(savedDateString)")
            }

            // Schedule the next update at midnight
            let nextUpdate = Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0), matchingPolicy: .nextTime) ?? Date().addingTimeInterval(86400)

            // Return the timeline
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

struct DailyIconEntry: TimelineEntry {
    let date: Date
    let image: UIImage?
    let description: String?
}

struct AgiosWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if let icon = entry.image {
            ZStack(alignment: .bottom) {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 169, height: 169)
                    .scaleEffect(1.04)
                
                Text(entry.description ?? "")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .font(.system(size: 12))
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).foregroundStyle(.black.opacity(0.5)))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 6)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
            }
        } else {
            placeholderImage
        }
    }
    
    var placeholderImage: some View {
        Image("placeholder")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AgiosWidget: Widget {
    let kind: String = "AgiosWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AgiosWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.white
                }
        }
        .configurationDisplayName("Agios Widget")
        .description("A Coptic icon on your home screen that updates daily so you never miss a Saint's Feast ever again!")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    AgiosWidget()
} timeline: {
    DailyIconEntry(date: .now, image: UIImage(named: "placeholder")!, description: "a very long description")
}
