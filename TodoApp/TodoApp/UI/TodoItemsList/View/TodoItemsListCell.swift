//
//  TodoItemsListCell.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 27.06.2023.
//

import Foundation
import UIKit
import SnapKit

protocol CellRendring {
    func render(props: TodoItemCellProps)
}

class TodoItemsListCell: UITableViewCell, CellRendring {
    lazy var checkButton: CheckButtonRendering = {
        let button = CheckButton()
        button.awakeFromNib()
        return button
    }()
    
    lazy var label: UILabel = {
        let view = UILabel()
        view.numberOfLines = 3
        view.lineBreakMode = .byTruncatingTail
        view.font = .systemFont(ofSize: 17)
        return view
    }()
    
    lazy var importanceImage: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var labelOfDeadline: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 15)
        view.textColor = .lightGray
        return view
    }()
    
    lazy var deadline: UIView = {
        let view = UIView()
        //view.frame.size = CGSize(width: 73, height: 20)
        let config = UIImage.SymbolConfiguration(scale: .small)
        let symbolImage = UIImage(systemName: "calendar", withConfiguration: config)
        let templateImage = symbolImage?.withRenderingMode(.alwaysTemplate)
        let calendarImage = UIImageView(image: templateImage)
        calendarImage.tintColor = .lightGray
    
        view.addSubview(calendarImage)
        
        calendarImage.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
        }
    
        return view
    }()
    
    lazy var chevron: UIImageView = {
        let symbolImage = UIImage(systemName: "chevron.right")
        let templateImage = symbolImage?.withRenderingMode(.alwaysTemplate)
        let view = UIImageView(image: templateImage)
        view.tintColor = .gray
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(named: "interfaceColor")
        
        contentView.addSubview(checkButton)
        contentView.addSubview(label)
        contentView.addSubview(chevron)
        contentView.addSubview(deadline)
        contentView.addSubview(labelOfDeadline)
        contentView.addSubview(importanceImage)
        
        checkButton.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview().inset(16)
        }
        
        chevron.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).inset(16)
            make.centerY.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(68)
            make.bottom.top.equalToSuperview().inset(16)
        }
        
        deadline.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(68)
            make.top.equalTo(label.snp_bottomMargin).offset(2)
        }
        
        labelOfDeadline.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(86)
            make.top.equalTo(label.snp_bottomMargin).offset(2)
        }
        
        importanceImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(checkButton.snp_rightMargin).offset(12)
        }
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapButton(props: TodoItemCellProps.CheckButtonProps) {
        
        checkButton.tapButton(props: props)
    }
    
    func render(props: TodoItemCellProps) {
        checkButton.render(props: props.checkButtonProps)
        if let deadline = props.deadline {
            labelOfDeadline.text = deadline
            self.deadline.isHidden = false
        } else {
            labelOfDeadline.text = ""
            deadline.isHidden = true
        }
        
        importanceImage.isHidden = false
        
        switch props.checkButtonProps.importance {
        case .important:
            importanceImage.image = UIImage(named: "excplanationMark")
            checkButton.layer.borderColor = UIColor.systemRed.cgColor
        case .unimportant:
            importanceImage.image = UIImage(systemName: "arrow.down")?.withRenderingMode(.alwaysOriginal).withTintColor(.lightGray)
        default:
            importanceImage.isHidden = true
        }
        if props.checkButtonProps.isDone {
            label.textColor = .gray
            let attributes = NSMutableAttributedString(string: props.text, attributes: [.strikethroughStyle: 2])
            label.attributedText = attributes
        } else {
            label.textColor = UIColor(named: "textColor")
            label.attributedText = nil
            label.text = props.text
        }
    }
}


