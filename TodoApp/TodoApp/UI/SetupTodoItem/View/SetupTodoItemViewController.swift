//
//  SetupTodoItemViewController.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 22.06.2023.
//

import Foundation
import UIKit
import SnapKit

class SetupTodoItemViewController: UIViewController {
    private let presenter: SetupTodoItemPresenterProtocol
    
    private lazy var mainView: SetupTodoItemView = {
        let view = SetupTodoItemView()
        view.delegate = self
        view.isUserInteractionEnabled = true
        return view
    }()
    
    init(presenter: SetupTodoItemPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    
        view.addSubview(mainView)
        let saveButton = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(saveTodoItem))
        navigationItem.title = "Дело"
        navigationItem.rightBarButtonItem = saveButton
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func saveTodoItem() {
        presenter.saveTodoItem()
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

extension SetupTodoItemViewController: SetupTodoItemViewDelegate {
    func deleteTodoItem() {
        presenter.deleteTodoItem()
    }
    
    func updateImportance(importance: Importance) {
        presenter.updateImportance(importance: importance)
    }
    
    func updateDescriptionField(text: String) {
        presenter.updateDescriptionField(text: text)
    }
    
    func dateDidChanged(date: Date) {
        presenter.dateDidChanged(date: date)
    }
}
