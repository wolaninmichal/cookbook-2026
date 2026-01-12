//
//  BlisterBottomRowCell.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 12/01/2026.
//

import UIKit
import SnapKit

final class BlisterBottomRowCell: UITableViewCell {

    static let reuseID = String(describing: BlisterBottomRowCell.self)

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    private func configureUI() {
        selectionStyle = .none
        contentView.backgroundColor = .systemBackground

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label

        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(titleLabel)
            $0.bottom.equalToSuperview().inset(16)
        }
    }

    func configure(with vm: BlisterBottomVM) {
        titleLabel.text = vm.title
        subtitleLabel.text = vm.subtitle
    }
}
