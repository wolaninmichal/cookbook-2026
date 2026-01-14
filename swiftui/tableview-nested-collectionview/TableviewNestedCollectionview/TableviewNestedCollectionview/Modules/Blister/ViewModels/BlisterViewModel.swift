//
//  BlisterViewModel.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 13/01/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class BlisterViewModel {

    private(set) var pages: [BlisterPage]
    private(set) var bottom: BlisterBottom

    var currentPageID: UUID?
    var selection: SquareSelection?

    init(
        pages: [BlisterPage] = [
            BlisterPage(itemsCount: 50),
            BlisterPage(itemsCount: 50)
        ],
        bottom: BlisterBottom = BlisterBottom(
            title: "Bottom line.",
            subtitle: "Place for a second view."
        )
    ) {
        self.pages = pages
        self.bottom = bottom
        self.currentPageID = pages.first?.id
    }

    func didTapSquare(pageID: UUID, index: Int) {
        selection = SquareSelection(pageID: pageID, index: index)
    }
}
