//
//  UIView+Additional.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 23.06.2023.
//

import Foundation
import UIKit

public extension UIView {
    @discardableResult
    func forAutolayout() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        return self
    }
}
