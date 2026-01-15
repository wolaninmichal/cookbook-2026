//
//  BlisterVM.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 12/01/2026.
//

import UIKit

final class BlisterVM {
    // MARK: - Nested "models"
    struct Page: Hashable {
        let id: UUID = .init()
        let itemsCount: Int
    }

    struct Bottom {
        let title: String
        let subtitle: String
    }

    enum Row: Int, CaseIterable {
        case blister
        case bottom
    }

    // MARK: - MVVM outputs
    var onReload: (() -> Void)?
    var onRoute: ((Route) -> Void)?

    enum Route {
        case showBottomDetails
        case showPage(id: UUID)
    }

    // MARK: - State
    private(set) var pages: [Page]
    private(set) var bottom: Bottom

    // MARK: - Init
    init(
        pages: [Page] = [.init(itemsCount: 50), .init(itemsCount: 50)],
        bottom: Bottom = .init(title: "Bottom line.", subtitle: "Place for a second view."),
    ) {
        self.pages = pages
        self.bottom = bottom
    }

    // MARK: - Inputs (Actions)
    enum Action {
        case viewDidLoad
        case bottomTapped
        case pageTapped(id: UUID)
    }

    func send(_ action: Action) {
        switch action {
        case .viewDidLoad:
            onReload?()

        case .bottomTapped:
            onRoute?(.showBottomDetails)

        case .pageTapped(let id):
            onRoute?(.showPage(id: id))
        }
    }

    // MARK: - tV helpers
    func numberOfRows() -> Int { Row.allCases.count }

    func row(at index: Int) -> Row {
        Row(rawValue: index) ?? .blister
    }
}
