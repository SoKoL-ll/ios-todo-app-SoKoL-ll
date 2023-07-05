//
//  TodoAppWidgetView.swift
//  TodoAppWidgetExtension
//
//  Created by Alexandr Sokolov on 03.07.2023.
//

import Foundation
import SwiftUI
import TodoItemPackage

struct TodoAppWidgetView: View {
    let todoItem: TodoItem?
    let gradient = Gradient(colors: [.red, .black, .pink, .purple])
    var body: some View {
        if let todoItem = todoItem {
            HStack {
                Text(todoItem.text)
                Text("Deadline этой задачи сегодня!!!")
                    .foregroundColor(.black)
                    .font(.system(.title3))
                    .multilineTextAlignment(.leading)
                    .padding(.bottom)
                    .padding(.leading)
                    .padding(.trailing)
            }
            .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity, alignment: .center)
            .background(AngularGradient(gradient: gradient, center: .bottomLeading))
        } else {
            Text("Сегодня\nможно\nотдыхать😎")
                .foregroundColor(.black)
                .font(.system(.title3))
                .multilineTextAlignment(.leading)
                .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity, alignment: .center)
                .background(AngularGradient(gradient: gradient, center: .bottomLeading))
        }
    }
}
