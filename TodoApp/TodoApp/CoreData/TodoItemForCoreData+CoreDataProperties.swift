//
//  TodoItemForCoreData+CoreDataProperties.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 14.07.2023.
//
//

import Foundation
import CoreData


extension TodoItemForCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItemForCoreData> {
        return NSFetchRequest<TodoItemForCoreData>(entityName: "TodoItemForCoreData")
    }

    @NSManaged public var changedAt: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var deadline: Date?
    @NSManaged public var done: Bool
    @NSManaged public var id: String?
    @NSManaged public var importance: String?
    @NSManaged public var text: String?

}

extension TodoItemForCoreData : Identifiable {

}
