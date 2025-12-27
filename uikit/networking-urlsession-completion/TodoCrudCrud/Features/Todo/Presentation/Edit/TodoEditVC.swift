//
//  TodoEditVC.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 21/12/2025.
//

import UIKit
import SnapKit

final class TodoEditVC: UIViewController {
    
    private let vm: TodoEditVM
    
    private let titleField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Title"
        tf.autocapitalizationType = .sentences
        return tf
    }()
    
    private let doneSwitch: UISwitch = .init()
    
    private let doneLabel: UILabel = {
        let lbl: UILabel = .init()
        lbl.text = "Done"
        return lbl
    }()
    
    private lazy var doneRow: UIStackView = {
        let s = UIStackView(arrangedSubviews: [doneLabel, doneSwitch])
        s.axis = .horizontal
        s.alignment = .center
        s.distribution = .equalSpacing
        return s
    }()
    
    private lazy var stack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [titleField, doneRow])
        s.axis = .vertical
        s.spacing = 16
        return s
    }()
    
    init(vm: TodoEditVM){
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required
    init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add/Edit task"
        
        setup()
        sBindings()
        
        titleField.text = vm.initialTitle
        doneSwitch.isOn = vm.initialIsDone
    }
    
    private func setup() {
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
        
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func sBindings() {
        vm.onError = { [weak self] message in
            let alert = UIAlertController(title: "Błąd", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    @objc
    private func saveTapped() {
        vm.save(title: titleField.text ?? "", isDone: doneSwitch.isOn)
    }
}
