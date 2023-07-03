//
//  SetupTodoItemView.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 22.06.2023.
//

import Foundation
import UIKit

class SetupTodoItemView: UIView {
    private var props: TodoItemProps?
    
    private let descriptionField = UITextView().applying { textField in
        textField.font = .systemFont(ofSize: 17)
        textField.textColor = UIColor(named: "textColor")
        textField.layer.cornerRadius = 16
        textField.layer.borderWidth = 0
        textField.layer.masksToBounds = true
        textField.backgroundColor = UIColor(named: "interfaceColor")
        textField.returnKeyType = .done
        textField.keyboardType = .default
        textField.textAlignment = .left
        textField.isScrollEnabled = false
        textField.text = "Что хотите cделать?"
        textField.textColor = UIColor.lightGray
        textField.clipsToBounds = true
    }
    
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 0
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = UIColor(named: "interfaceColor")
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(deleteButtonDidTap), for: .touchDown)
        
        return button
    }()
    
    private lazy var optionsStackView: UIStackView = {
        let view = UIStackView()
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 0
        view.backgroundColor = UIColor(named: "interfaceColor")
        view.axis = .vertical
        view.spacing = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var separatorViewForImportance: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        
        return view
    }()
    
    private lazy var separatorViewForDate: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.isHidden = true
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        
        return view
    }()
    
    private lazy var chooseImportance = ChooseImportantView()
    
    private lazy var chooseData = ChooseDataView()
    
    private lazy var scrollView: CustomScrollView = {
        let view = CustomScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor(named: "backgroundColor")
        descriptionField.delegate = self
        addSubviews()
        setConstraints()
        chooseData.datePicker.addTarget(self, action: #selector(dataSelected), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func dataSelected() {
        props?.updateDate?(chooseData.datePicker.date)
    }
    
    private func addSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(descriptionField)
        mainStackView.addArrangedSubview(optionsStackView)
        scrollView.addSubview(deleteButton)
        [
            chooseImportance,
            separatorViewForImportance,
            chooseData,
            separatorViewForDate,
            chooseData.datePicker
        ].forEach { optionsStackView.addArrangedSubview($0) }
    }
    
    private func setConstraints() {
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        descriptionField.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.left.right.equalToSuperview().inset(16)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(120)
        }
        
        optionsStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionField.snp.bottom).offset(16)
            make.trailing.bottom.equalToSuperview()
        }
        
        chooseImportance.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        
        chooseData.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        
        separatorViewForDate.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.left.right.equalToSuperview().inset(32)
        }
        
        separatorViewForImportance.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.left.right.equalToSuperview().inset(32)
        }
        
        chooseData.datePicker.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(optionsStackView.snp.bottom).offset(16)
            make.trailing.bottom.equalToSuperview()
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }
    }
    
    @objc func textFieldTapDone(sender: Any) {
        descriptionField.endEditing(true)
    }
    
    @objc func deleteButtonDidTap() {
        props?.deleteItem?()
    }
    
    func closeDescriptionFieldIfNeeded(point: CGPoint) {
        if !descriptionField.point(inside: point, with: .none) {
            descriptionField.resignFirstResponder()
        }
    }
    
    func setContentInsert(isHidden: Bool, keyboardHeight: CGFloat) {
        if isHidden {
            descriptionField.contentInset = UIEdgeInsets.zero
        } else {
            descriptionField.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
        descriptionField.scrollRangeToVisible(descriptionField.selectedRange)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let getKeyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }
        
        let keyboardFrame = convert(getKeyboardRect, to: window)
        var inset = scrollView.contentInset
        inset.bottom = keyboardFrame.size.height - 25
        scrollView.contentInset = inset
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SetupTodoItemView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionField.textColor == UIColor.lightGray {
            descriptionField.text = ""
            descriptionField.textColor = UIColor(named: "textColor")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionField.text == "" {
            descriptionField.text = "Что хотите сделать?"
            descriptionField.textColor = UIColor.lightGray
        } else {
            props?.textDidChange?(descriptionField.text)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if descriptionField.text == "" {
            descriptionField.text = "Что хотите сделать?"
            descriptionField.textColor = UIColor.lightGray
        } else {
            props?.textDidChange?(descriptionField.text)
        }
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        if estimatedSize.height > 120 {
            textView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
    }
}

extension SetupTodoItemView {
    func render(props: TodoItemProps?) {
        self.props = props
        descriptionField.text = props?.text
        if descriptionField.text != "" {
            descriptionField.textColor = UIColor(named: "textColor")
        } else {
            descriptionField.text = "Что хотите сделать?"
            descriptionField.textColor = UIColor.lightGray
        }
        self.chooseImportance.render(props: props)
        self.chooseData.render(props: props)
    }
}
