//
//  TodoItemsListPresenterProtocol.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 27.06.2023.
//

import Foundation
import UIKit

protocol TodoItemsListPresenterProtocol: AnyObject {
    func build()
    func open() -> UIViewController
}
