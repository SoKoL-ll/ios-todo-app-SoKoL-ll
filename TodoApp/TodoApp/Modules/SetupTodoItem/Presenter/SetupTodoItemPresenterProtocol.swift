//
//  SetupTodoItemPresenterProtocol.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 22.06.2023.
//

import Foundation
import UIKit

protocol SetupTodoItemPresenterProtocol: AnyObject {
    func build()
    func open() -> UIViewController
    func setupWithTodoItem(id: String, revision: Int)
}
