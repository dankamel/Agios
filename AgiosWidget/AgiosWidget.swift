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
            guard let saint = try? await WidgetService.fetchSaint() else {
                return
            }
            
            // Create the entry inside the Task
            let entry = DailyIconEntry(date: Date(),
                                       image: saint.image,
                                       description: saint.description)
            
            // Schedule the next update for midnight
            let nextUpdate = Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0), matchingPolicy: .nextTime)!
            
            // Create the timeline and call the completion inside the Task
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
                
                Text(entry.description ?? "No image available")
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
