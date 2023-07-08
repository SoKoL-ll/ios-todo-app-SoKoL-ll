//
//  NSObjectProtocol+Additional.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 23.06.2023.
//

import Foundation

public extension NSObjectProtocol {
    @inlinable
    @inline(__always)
    @discardableResult
    func applying(_ function: (Self) -> Void) -> Self {
        function(self)
        
        return self
    }
}
