//
//  SetupTodoItemViewController.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 22.06.2023.
//

import Foundation
import UIKit
import SnapKit

protocol SetupTodoItemRendering {
    func render(props: TodoItemProps)
}

class SetupTodoItemViewController: UIViewController {
    private var props: TodoItemProps?
    
    private lazy var mainView: SetupTodoItemView = {
        let view = SetupTodoItemView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    
        view.addSubview(mainView)
        let saveButton = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(saveTodoItem))
        let cancelButton = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(cancelTodoItem))
        navigationItem.title = "Дело"
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = cancelButton
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func saveTodoItem() {
        props?.saveTodoItem?()
    }
    
    @objc func cancelTodoItem() {
        props?.cancel?()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: mainView)
        
        mainView.closeDescriptionFieldIfNeeded(point: point)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SetupTodoItemViewController: SetupTodoItemRendering {
    func render(props: TodoItemProps) {
        self.props = props
        self.mainView.render(props: props)
    }
}
