//
//  ItemCell.swift
//  PersistenceRealmTodoList
//
//  Created by Michał Wolanin on 10/02/2026.
//

import UIKit
import SnapKit

final class ItemCell: UITableViewCell {
    
    static var reuseID: String { String(describing: Self.self) }
    
    private let titleLabel: UILabel = .init()
    private let checkmarkView: UIImageView = .init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func setup() {
        sView()
        sLayout()
    }
    
    private func sView() {
        accessoryType = .none
        accessoryView = .none
        
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkView)
        
        checkmarkView.contentMode = .scaleAspectFit
    }
    
    private func sLayout() {
        checkmarkView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkmarkView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(8)
        }
    }
    
    func configure(with item: TodoItem) {
        titleLabel.text = item.title
        let imageName = item.isDone ? "checkmark.circle.fill" : "circle"
        checkmarkView.image = UIImage(systemName: imageName)
        titleLabel.textColor = item.isDone ? .secondaryLabel : .label
    }
}
