//
//  ChooseDataView.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 30.06.2023.
//

import Foundation
import UIKit

class ChooseDataView: UIView {
    let view = UIView()
    let label = UILabel()
    let dateSwitch = UISwitch()
    var props: TodoItemProps?
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.backgroundColor = UIColor(named: "interfaceColor")
        datePicker.isHidden = true
        datePicker.date = Calendar.current.date(byAdding: .day, value: 1, to: datePicker.date) ?? datePicker.date
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
    
    @objc func buttonDateDidTapped() {
        props?.didOpenDatapiker?()
    }
    
    init() {
        super.init(frame: .zero)
        
        label.text = "Сделать до"
        addSubview(label)
        addSubview(dateSwitch)
        addSubview(buttonDate)
        
        dateSwitch.addTarget(self, action: #selector(switchDidChange), for: .valueChanged)
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
    }
    
    @objc func switchDidChange() {
        props?.switchChange?()
    }
    
    func render(props: TodoItemProps?) {
        self.props = props
        checkSwitch(flag: props?.isSwitcherState ?? false)
        guard let deadline = props?.deadline else { return }
        
        showDatePicker(flag: props?.isDataPickerOpen ?? false)
        buttonDate.setTitle(deadline.toString(), for: .normal)
        datePicker.date = deadline
    }
    
    private func checkSwitch(flag: Bool) {
        if flag {
            buttonDate.isHidden = false
            dateSwitch.setOn(true, animated: true)
        } else {
            dateSwitch.setOn(false, animated: true)
            buttonDate.isHidden = true
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) { [weak self] in
                guard let self else { return }
                self.datePicker.isHidden = true
            }
        }
    }
    
    private func showDatePicker(flag: Bool) {
        if !flag && props?.isSwitcherState ?? false {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) { [weak self] in
                guard let self else { return }
                self.datePicker.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) { [weak self] in
                guard let self else { return }
                self.datePicker.isHidden = true
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
