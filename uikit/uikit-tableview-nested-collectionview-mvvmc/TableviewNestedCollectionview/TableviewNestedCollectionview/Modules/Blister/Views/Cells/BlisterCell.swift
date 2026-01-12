//
//  BlisterCell.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 12/01/2026.
//

import UIKit
import SnapKit

final class BlisterCell: UICollectionViewCell {

    static let reuseID = String(describing: BlisterCell.self)

    private enum Const {
        static let rows: Int = 5
        static let cols: Int = 10
        static let spacing: CGFloat = 6
        static let inset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        return v
    }()

    private lazy var internalLayout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .vertical
        l.minimumLineSpacing = Const.spacing
        l.minimumInteritemSpacing = Const.spacing
        l.sectionInset = Const.inset
        return l
    }()

    private lazy var internalCollection: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: internalLayout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.dataSource = self
        cv.register(BlisterSquareCell.self, forCellWithReuseIdentifier: BlisterSquareCell.reuseID)
        return cv
    }()

    private var vm: BlisterPageVM?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        vm = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateSquareItemSize()
    }

    private func configureUI() {
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(internalCollection)

        cardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        internalCollection.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func configure(with vm: BlisterPageVM) {
        self.vm = vm
        internalCollection.reloadData()
        internalCollection.layoutIfNeeded()
        updateSquareItemSize()
    }

    private func updateSquareItemSize() {
        let bounds = internalCollection.bounds.inset(by: Const.inset)
        guard bounds.width > 0 else { return }

        let totalHSpacing = CGFloat(Const.cols - 1) * Const.spacing
        let side = floor((bounds.width - totalHSpacing) / CGFloat(Const.cols))
        guard side > 0 else { return }

        internalLayout.itemSize = CGSize(width: side, height: side)
        internalLayout.invalidateLayout()
    }
}

extension BlisterCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm?.itemsCount ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BlisterSquareCell.reuseID,
            for: indexPath
        ) as? BlisterSquareCell else { return UICollectionViewCell() }

        cell.configure(index: indexPath.item)
        return cell
    }
}
