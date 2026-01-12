//
//  BlisterSquareCell.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 12/01/2026.
//

import UIKit

final class BlisterSquareCell: UICollectionViewCell {

    static let reuseID = String(describing: BlisterSquareCell.self)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .systemBlue.withAlphaComponent(0.25)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .systemBlue.withAlphaComponent(0.25)
    }

    func configure(index: Int) {  }
}
