//
//  BlisterRowCell.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 12/01/2026.
//

import UIKit
import SnapKit

final class BlisterRowCell: UITableViewCell {

    static let reuseID = String(describing: BlisterRowCell.self)

    private let headerLabel = UILabel()

    private lazy var externalLayout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .horizontal
        l.minimumLineSpacing = 12
        l.minimumInteritemSpacing = 12
        l.sectionInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        return l
    }()

    private lazy var externalCollection: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: externalLayout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceHorizontal = true
        cv.decelerationRate = .fast

        cv.dataSource = self
        cv.delegate = self

        cv.register(BlisterCell.self, forCellWithReuseIdentifier: BlisterCell.reuseID)
        return cv
    }()

    private var pages: [BlisterVM.Page] = []
    var onPageTapped: ((UUID) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        pages = []
        onPageTapped = nil
        headerLabel.text = nil
        externalCollection.setContentOffset(.zero, animated: false)
    }

    private func configureUI() {
        selectionStyle = .none
        contentView.backgroundColor = .systemBackground

        headerLabel.font = .preferredFont(forTextStyle: .headline)
        headerLabel.textColor = .label
        headerLabel.text = "Blister"

        contentView.addSubview(headerLabel)
        contentView.addSubview(externalCollection)

        headerLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }

        externalCollection.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(135)
            $0.bottom.equalToSuperview().inset(16).priority(.low)
        }
    }

    func configure(with pages: [BlisterVM.Page]) {
        self.pages = pages
        externalCollection.reloadData()
        externalCollection.layoutIfNeeded()
        externalCollection.setContentOffset(.zero, animated: false)
    }
}

extension BlisterRowCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BlisterCell.reuseID,
            for: indexPath
        ) as? BlisterCell else { return UICollectionViewCell() }

        cell.configure(with: pages[indexPath.item])
        return cell
    }
}

extension BlisterRowCell: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let insets = externalLayout.sectionInset
        let width = max(0, collectionView.bounds.width - insets.left - insets.right)
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }
}

extension BlisterRowCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onPageTapped?(pages[indexPath.item].id)
    }
}
