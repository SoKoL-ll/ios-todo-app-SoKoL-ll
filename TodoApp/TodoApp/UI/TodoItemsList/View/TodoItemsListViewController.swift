//
//  TodoItemsListViewController.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 27.06.2023.
//

import Foundation
import UIKit
import CocoaLumberjack

protocol Rendering {
    func render(props: TodoItemsProps)
}

class TodoItemsListViewController: UIViewController {
    private var props: TodoItemsProps?
    
    private let tableHeadView = TableHeaderView().applying { view in
        view.frame.size.height = 32
    }
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped).applying { view in
        view.separatorStyle = .singleLine
        view.backgroundColor = UIColor(named: "backgroundColor")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(TodoItemsListCell.self, forCellReuseIdentifier: "TodoItemsListCell")
        view.estimatedRowHeight = 56
        view.rowHeight = UITableView.automaticDimension
    }
    
    private let addButton: UIButton = {
        let view = UIButton()
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.3
        view.setImage(UIImage(systemName: "plus.circle.fill",
                              withConfiguration: UIImage.SymbolConfiguration(
                                pointSize: 44
                              )
                             )?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBlue), for: .normal)
        view.addTarget(nil, action: #selector(createNewCell), for: .touchUpInside)
        return view
    }()
    
    @objc func createNewCell() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        props?.createCell?()
    }

    override func viewDidLoad() {
        DDLog.add(DDOSLogger.sharedInstance)
        title = "Мои дела"
        setupTableView()
        setupConstraints()
    }
    
    func setupTableView() {
        tableView.tableHeaderView = tableHeadView
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupConstraints() {
        view.addSubview(tableView)
        view.addSubview(addButton)
        tableView.snp.makeConstraints { make in
            make.bottom.top.leading.trailing.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(42)
        }
    }
}

extension TodoItemsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemsListCell") as? TodoItemsListCell else { return }
        cell.transform = CGAffineTransform(translationX: 0, y: cell.contentView.frame.height)
        UIView.animate(withDuration: 5.0, delay: 0.05 * Double(indexPath.row), animations: {
              cell.transform = CGAffineTransform(translationX: cell.contentView.frame.width, y: cell.contentView.frame.height)
        }) { _ in
                    self.props?.todoItemsCells[indexPath.row].openCell?()
                }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionRemove = UIContextualAction(style: .destructive, title: nil) { _, _, completionHandler in
            self.props?.todoItemsCells[indexPath.row].deleteCell?()
            completionHandler(true)
        }
        actionRemove.backgroundColor = .systemRed
        actionRemove.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [actionRemove])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionDone = UIContextualAction(style: .normal, title: nil) { _, _, completionHandler in
            self.props?.todoItemsCells[indexPath.row].checkButtonProps.onToggle?()
            completionHandler(true)
        }
        
        actionDone.backgroundColor = .systemGreen
        actionDone.image = UIImage(systemName: "checkmark.circle.fill")
        return UISwipeActionsConfiguration(actions: [actionDone])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        props?.todoItemsCells.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemsListCell") as? TodoItemsListCell else {
            return TodoItemsListCell()
        }
        guard let propsItem = props?.todoItemsCells[indexPath.row] else { return TodoItemsListCell() }
        
        cell.render(props: propsItem)
        
        return cell
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            let vc = SetupTodoItemViewController()
            vc.render(props: TodoItemProps(text: self.props?.todoItemsCells[indexPath.row].text ?? "",
                                           importance: self.props?.todoItemsCells[indexPath.row].checkButtonProps.importance ?? .common,
                                           isDataPickerOpen: false,
                                           isSwitcherState: self.props?.todoItemsCells[indexPath.row].deadline != nil,
                                           didOpenDatapiker: nil,
                                           textDidChange: nil,
                                           switchChange: nil,
                                           setNewDate: nil,
                                           cancel: nil,
                                           saveTodoItem: nil,
                                           updateDate: nil,
                                           updateImportance: nil,
                                           deleteItem: nil))
            return vc
        }, actionProvider: nil)
    }
}

extension TodoItemsListViewController: Rendering {
    func render(props: TodoItemsProps) {
        self.props = props
        tableHeadView.render(props: props.tableHeaderProps)
        tableView.reloadData()
    }
}

class TableHeaderView: UIView {
    let label = UILabel()
    let button = UIButton()
    var props: TodoItemsProps.TableHeaderProps?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textColor = .lightGray
        button.setTitle("Показать", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(didButtonTap), for: .touchUpInside)
        addSubview(label)
        addSubview(button)
        
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(32)
            make.centerY.equalToSuperview()
        }
        button.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(32)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc func didButtonTap() {
        props?.showDone?()
    }

    func render(props: TodoItemsProps.TableHeaderProps) {
        self.props = props
        if props.isShowAll {
            button.setTitle("Показать", for: .normal)
        } else {
            button.setTitle("Скрыть", for: .normal)
        }
            
        label.text = "Выполнено - \(props.numberOdone)"
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
