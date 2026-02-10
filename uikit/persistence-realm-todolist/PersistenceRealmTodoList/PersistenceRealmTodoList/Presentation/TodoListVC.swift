//
//  TodoListVC.swift
//  PersistenceRealmTodoList
//
//  Created by Michał Wolanin on 10/02/2026.
//

import UIKit
import SnapKit

final class TodoListVC: UIViewController {
    let vm: TodoListVM
    
    let tableView: UITableView = .init(frame: .zero, style: .plain)
    
    init(vm: TodoListVM){
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        vm.viewDidLoad()
    }
    
    private func setup() {
        sView()
        sTableView()
        sLayout()
        sBindings()
    }
    
    private func sView() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
    }
    
    private func sTableView() {
        view.addSubview(tableView)

        tableView.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func sLayout() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func sBindings() {
        vm.onChange = { [weak self] change in
            guard let self = self else { return }
            
            switch change {
            case .initial:
                self.tableView.reloadData()
                
            case .update(let deletions, let insertions, let modifications):
                self.tableView.performBatchUpdates({
                    self.tableView.deleteRows(at: deletions, with: .automatic)
                    self.tableView.insertRows(at: insertions, with: .automatic)
                    self.tableView.reloadRows(at: modifications, with: .automatic)
                })
                
            case .error(let error):
                print("UITableView change error: \(error)")
            }
        }
    }
    
    @objc private func addButtonTapped() {
        let alert = UIAlertController(title: "New task",
                                      message: "Enter title",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Buy some milk"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let self, let text = alert.textFields?.first?.text else { return }
            self.vm.addTask(title: text)
        }))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TodoListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ItemCell.reuseID,
            for: indexPath)
                as? ItemCell else {
            return UITableViewCell()
        }
        
        let item = vm.item(at: indexPath)
        cell.configure(with: item)
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension TodoListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        vm.toggleTask(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Usuń") { [weak self] _, _, completion in
            self?.vm.deleteTask(at: indexPath)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
