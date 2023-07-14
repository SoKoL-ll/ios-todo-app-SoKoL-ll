//
//  TodoAppWidget.swift
//  TodoAppWidget
//
//  Created by Alexandr Sokolov on 03.07.2023.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct TodoAppWidgetEntryView : View {
    var entry: Provider.Entry

//    var fileCache = FileCache()
//
//    func searchDeadlineItems() -> TodoItem? {
//        fileCache.loadTodoItemsFromJsonFile(file: "TodoItems.json")
//
//        for item in fileCache.todoItems {
//            guard let deadline = item.value.deadline else {
//                continue
//            }
//            if deadline.toString() == Date().toString() {
//                return item.value
//            }
//        }
//        return nil
//    }
    var body: some View {
        Text("kaka")
//        TodoAppWidgetView(todoItem: searchDeadlineItems())
    }
}

struct TodoAppWidget: Widget {
    let kind: String = "TodoAppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodoAppWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct TodoAppWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodoAppWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
