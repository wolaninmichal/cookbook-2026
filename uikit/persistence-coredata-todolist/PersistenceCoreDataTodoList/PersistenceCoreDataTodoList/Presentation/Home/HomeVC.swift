//
//  HomeVC.swift
//  PersistenceCoreDataTodoList
//
//  Created by Michał Wolanin on 07/02/2026.
//

import UIKit
import SnapKit
import CoreData

final class HomeVC: UIViewController {
    private let vm: HomeVM
    private let tableView: UITableView = .init(frame: .zero, style: .plain)

    private typealias SectionID = HomeModels.SectionID
    private typealias ItemID = HomeModels.ItemID
    private typealias Snapshot = HomeModels.Snapshot

    private lazy var dataSource: UITableViewDiffableDataSource<SectionID, ItemID> = {
        let ds = UITableViewDiffableDataSource<SectionID, ItemID>(
            tableView: tableView
        ) { [weak self] tableView, indexPath, objectID in
            guard let self else { return UITableViewCell() }

            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ItemCell.reuseID,
                for: indexPath
            ) as? ItemCell else {
                return UITableViewCell()
            }

            do {
                let dto = try self.vm.dto(for: objectID)
                cell.configure(with: dto)
            } catch {
                cell.textLabel?.text = "—"
            }

            return cell
        }

        ds.defaultRowAnimation = .automatic
        return ds
    }()

    init(vm: HomeVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
        vm.viewDidLoad()
    }

    private func setup() {
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )

        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        tableView.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reuseID)
        tableView.delegate = self
        tableView.dataSource = dataSource
    }

    private func bind() {
        vm.onSnapshot = { [weak self] snapshot in
            guard let self else { return }
            let animate = (self.view.window != nil)
            self.dataSource.apply(snapshot, animatingDifferences: animate)
        }

        vm.onError = { error in
            print("HomeVM error: \(error)")
        }
    }

    @objc private func addButtonTapped() {
        let alert = UIAlertController(
            title: "New task",
            message: "Enter title:",
            preferredStyle: .alert
        )

        alert.addTextField { $0.placeholder = "E.g. buy eggs" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let self, let text = alert.textFields?.first?.text else { return }
            self.vm.addTask(title: text)
        }))

        present(alert, animated: true)
    }
}

extension HomeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        guard let objectID = dataSource.itemIdentifier(for: indexPath) else { return }
        vm.toggleTask(objectID: objectID)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        guard let objectID = dataSource.itemIdentifier(for: indexPath) else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.vm.deleteTask(objectID: objectID)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
