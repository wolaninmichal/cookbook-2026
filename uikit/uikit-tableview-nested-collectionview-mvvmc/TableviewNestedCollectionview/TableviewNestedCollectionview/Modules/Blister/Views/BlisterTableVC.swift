//
//  BlisterTableVC.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 12/01/2026.
//

import UIKit
import SnapKit

final class BlisterTableVC: VC {

    private let vm: BlisterTableVM
    private let tableView = UITableView(frame: .zero, style: .plain)

    init(vm: BlisterTableVM) {
        self.vm = vm
        super.init()
        title = "uikit-tableview-nested-collectionview"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        bindVM()
        vm.viewDidLoad()
    }

    override func setupIphoneUI() { setupCommonUI() }
    override func setupIpadUI() { setupCommonUI() }

    private func setupCommonUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
    }

    private func configureTableView() {
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 260 

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(BlisterRowCell.self, forCellReuseIdentifier: BlisterRowCell.reuseID)
        tableView.register(BlisterBottomRowCell.self, forCellReuseIdentifier: BlisterBottomRowCell.reuseID)
    }

    private func bindVM() {
        vm.onReload = { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension BlisterTableVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.numberOfRows()
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        switch vm.row(at: indexPath.row) {
        case .blister:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: BlisterRowCell.reuseID,
                for: indexPath
            ) as? BlisterRowCell else { return UITableViewCell() }

            cell.configure(
                with: vm.blisterVM.pages,
                contentOffset: vm.blisterVM.lastContentOffset
            )

            cell.onContentOffsetChanged = { [weak self] offset in
                self?.vm.blisterVM.lastContentOffset = offset
            }

            return cell

        case .bottom:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: BlisterBottomRowCell.reuseID,
                for: indexPath
            ) as? BlisterBottomRowCell else { return UITableViewCell() }

            cell.configure(with: vm.bottomVM)
            return cell
        }
    }
}

extension BlisterTableVC: UITableViewDelegate { }
