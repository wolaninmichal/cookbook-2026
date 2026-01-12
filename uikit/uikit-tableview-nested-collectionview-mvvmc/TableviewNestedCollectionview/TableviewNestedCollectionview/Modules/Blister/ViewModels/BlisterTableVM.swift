//
//  BlisterTableVM.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 12/01/2026.
//

import UIKit

final class BlisterTableVM {

    var onReload: (() -> Void)?
    
    enum Row: Int, CaseIterable {
        case blister
        case bottom
    }

    private(set) var blisterVM: BlisterVM = BlisterVM(
        pages: [
            BlisterPageVM(itemsCount: 50),
            BlisterPageVM(itemsCount: 50)
        ]
    )

    private(set) var bottomVM: BlisterBottomVM = BlisterBottomVM(
        title: "Bottom line.",
        subtitle: "Place for a second view."
    )

    func viewDidLoad() {
        onReload?()
    }

    func numberOfRows() -> Int { Row.allCases.count }

    func row(at index: Int) -> Row {
        Row(rawValue: index) ?? .blister
    }
}
