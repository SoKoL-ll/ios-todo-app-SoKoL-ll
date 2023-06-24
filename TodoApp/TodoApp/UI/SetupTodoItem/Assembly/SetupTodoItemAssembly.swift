//
//  SetupTodoItemAsembly.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 22.06.2023.
//

import Foundation
import UIKit

class SetupTodoItemAssembly {
    func assembly() -> UIViewController {
        let presenter = SetupTodoItemPresenter()
        let viewController = SetupTodoItemViewController(presenter: presenter)
        
        return viewController
    }
}

