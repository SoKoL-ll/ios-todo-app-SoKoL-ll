//
//  checkButton.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 29.06.2023.
//

import Foundation
import UIKit

protocol CheckButtonRendering: UIButton {
    func render(props: TodoItemCellProps.CheckButtonProps)
    func tapButton(props: TodoItemCellProps.CheckButtonProps)
}

class CheckButton: UIButton, CheckButtonRendering {
    private var props: TodoItemCellProps.CheckButtonProps?
    let checkedImage = UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24))?.withRenderingMode(.alwaysOriginal).withTintColor(.lightGray)
    let uncheckedImage = UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemGreen)

    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                setImage(uncheckedImage, for: .normal)
            } else {
                if props?.importance == .important {
                    setImage(checkedImage?.withTintColor(.systemRed), for: .normal)
                } else {
                    setImage(checkedImage, for: .normal)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
    }
    
    @objc func buttonClicked(sender: UIButton) {
        self.props?.onToggle?()
    }
    
    func tapButton(props: TodoItemCellProps.CheckButtonProps) {
        self.props = props
        buttonClicked(sender: self)
    }
    
    func render(props: TodoItemCellProps.CheckButtonProps) {
        self.props = props
        isChecked = props.isDone
    }
}
