//
//  CustomScrollView.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 23.06.2023.
//

import Foundation
import UIKit

class CustomScrollView: UIScrollView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDragging {
            next?.touchesBegan(touches, with: event)
        } else {
        super.touchesBegan(touches, with: event)
        }
    }
}
