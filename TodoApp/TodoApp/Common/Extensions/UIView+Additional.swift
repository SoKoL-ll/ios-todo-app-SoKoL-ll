//
//  UIView+Additional.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 23.06.2023.
//

import Foundation
import UIKit

public extension UIView {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    
    @discardableResult
    func forAutolayout() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        return self
    }
}
