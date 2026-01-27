//
//  TodoVC.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 27/01/2026.
//

import UIKit
import SnapKit

final class TodoVC: UIViewController {

    private let vm: TodoVM

    private let tableView: UITableView = .init(frame: .zero, style: .plain)
    private let refresh: UIRefreshControl = .init()

    init(vm: TodoVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Todo"

        setup()
        vm.viewDidLoad()
    }

    private func setup() {
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(TodoListCell.self, forCellReuseIdentifier: TodoListCell.reuseID)

        refresh.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refresh

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )

        vm.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .loading:
                if !self.refresh.isRefreshing { self.refresh.beginRefreshing() }
            case .loaded:
                self.refresh.endRefreshing()
                self.tableView.reloadData()
            case .error(let msg):
                self.refresh.endRefreshing()
                self.presentError(msg)
            case .idle:
                break
            }
        }
    }

    @objc private func addTapped() {
        vm.addTapped()
    }

    @objc private func refreshPulled() {
        vm.reload()
    }
}

// MARK: - UITableViewDataSource
extension TodoVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.todos.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: TodoListCell.reuseID, for: indexPath) as! TodoListCell
        let item = vm.todos[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TodoVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        vm.didSelect(at: indexPath.row)
    }
}

// MARK: - Alert helper
extension UIViewController {
    func presentError(_ message: String) {
        let alert = UIAlertController(title: "Błąd", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
