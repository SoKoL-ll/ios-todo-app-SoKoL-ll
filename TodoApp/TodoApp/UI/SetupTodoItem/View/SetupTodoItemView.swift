//
//  SetupTodoItemView.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 22.06.2023.
//

import Foundation
import UIKit

protocol SetupTodoItemViewDelegate: AnyObject {
    func dateDidChanged(date: Date)
    func updateDescriptionField(text: String)
    func updateImportance(importance: Importance)
    func deleteTodoItem()
}

class SetupTodoItemView: UIView {
    weak var delegate: SetupTodoItemViewDelegate?
    
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
    
    private lazy var chooseImportance: UIView = {
        let view = UIView()
        let label = UILabel()
        let segmentControl = UISegmentedControl(items: [UIImage(systemName: "arrow.down") ?? "", "нет", UIImage(named: "excplanationMark") ?? ""])
        segmentControl.selectedSegmentIndex = 1
//        segmentControl.backgroundColor = UIColor(named: "segmentControlColor")
        label.text = "Важность"
        view.addSubview(label)
        view.addSubview(segmentControl)

        label.snp.makeConstraints { make in
            make.bottom.top.equalToSuperview()
            make.left.equalToSuperview().inset(16)
        }
        
        segmentControl.snp.makeConstraints { make in
            make.bottom.top.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(12)
            make.width.equalTo(150)
        }
        
        segmentControl.addTarget(self, action: #selector(segmentControlDidChanged), for: .valueChanged)
        return view
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.backgroundColor = UIColor(named: "interfaceColor")
        datePicker.isHidden = true
        datePicker.date = Calendar.current.date(byAdding: .day, value: 1, to: datePicker.date) ?? datePicker.date
        datePicker.addTarget(self, action: #selector(dataSelected), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var buttonDate: UIButton = {
        let buttonDate = UIButton()
        
        buttonDate.setTitle(datePicker.date.toString(), for: .normal)
        buttonDate.setTitleColor(.systemBlue, for: .normal)
        buttonDate.translatesAutoresizingMaskIntoConstraints = false
        buttonDate.titleLabel?.font = .systemFont(ofSize: 13)
        buttonDate.isHidden = true
        buttonDate.addTarget(self, action: #selector(buttonDateDidTapped), for: .touchDown)
        
        return buttonDate
    }()
    
    private lazy var chooseData: UIView = {
        let view = UIView()
        let label = UILabel()
        let dateSwitch = UISwitch()
        
        label.text = "Сделать до"
        view.addSubview(label)
        view.addSubview(dateSwitch)
        view.addSubview(buttonDate)
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.equalToSuperview().inset(16)
        }
        
        dateSwitch.snp.makeConstraints { make in
            make.bottom.top.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(12)
        }
    
        buttonDate.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalTo(label.snp.bottom)
            make.bottom.equalToSuperview().inset(8)
            make.height.equalTo(16)
        }
        
        dateSwitch.addTarget(self, action: #selector(dateSwitchDidChanged(paramGet:)), for: .valueChanged)
        return view
    }()
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
            datePicker
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
        
        datePicker.snp.makeConstraints { make in
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
    
    @objc private func dateSwitchDidChanged(paramGet: UISwitch) {
        if paramGet.isOn {
            buttonDate.isHidden = false
        } else {
            buttonDate.isHidden = true
            datePicker.isHidden = true
            separatorViewForDate.isHidden = true
        }
    }
    
    @objc private func buttonDateDidTapped() {
        if datePicker.isHidden {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) { [weak self] in
                guard let self else { return }
                self.datePicker.isHidden = false
                self.separatorViewForDate.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) { [weak self] in
                guard let self else { return }
                self.datePicker.isHidden = true
                self.separatorViewForDate.isHidden = true
            }
        }
    }
    
    @objc private func dataSelected() {
        buttonDate.setTitle(datePicker.date.toString(), for: .normal)
        delegate?.dateDidChanged(date: datePicker.date)
    }
   
    @objc private func hideDateSwitch() {
        datePicker.isHidden = true
    }
    
    @objc func textFieldTapDone(sender: Any) {
        descriptionField.endEditing(true)
    }
    
    @objc func segmentControlDidChanged(target: UISegmentedControl) {
        let segmentedIndex = target.selectedSegmentIndex
        switch segmentedIndex {
        case 0:
            delegate?.updateImportance(importance: .unimportant)
        case 2:
            delegate?.updateImportance(importance: .important)
        default:
            delegate?.updateImportance(importance: .common)
        }
    }
    
    @objc func deleteButtonDidTap() {
        delegate?.deleteTodoItem()
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
            delegate?.updateDescriptionField(text: descriptionField.text)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
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
