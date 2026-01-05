//
//  TodoListCell.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 20/12/2025.
//

import UIKit
import SnapKit

final class TodoListCell: UITableViewCell {
    
    static var reuseID: String { String(describing: Self.self) }

    private let statusImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.setContentCompressionResistancePriority(.required, for: .horizontal)
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .body)
        l.numberOfLines = 2
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .caption1)
        l.textColor = .secondaryLabel
        l.numberOfLines = 1
        return l
    }()
    
    private let rightStatusLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .caption1)
        l.textColor = .secondaryLabel
        l.textAlignment = .right
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        return l
    }()

    private lazy var labelsStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        s.axis = .vertical
        s.spacing = 4
        return s
    }()

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
        
    required
    init?(coder: NSCoder) { nil }
    
    private func setup() {
        selectionStyle = .default

        contentView.addSubview(statusImageView)
        contentView.addSubview(labelsStack)
        contentView.addSubview(rightStatusLabel)

        statusImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 22, height: 22))
        }

        rightStatusLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(60)
        }

        labelsStack.snp.makeConstraints { make in
            make.leading.equalTo(statusImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(rightStatusLabel.snp.leading).offset(-12)
            make.top.bottom.equalToSuperview().inset(10)
        }
    }
    
    func configure(with todo: Todo) {
        titleLabel.text = todo.title
        dateLabel.text = Self.dateFormatter.string(from: todo.createdAt)
        rightStatusLabel.text = todo.isDone ? "Done" : "Pending"

        let imageName = todo.isDone ? "checkmark.circle.fill" : "circle"
        statusImageView.image = UIImage(systemName: imageName)
        accessoryType = todo.isDone ? .checkmark : .none
    }
}
