//
//  BlisterPage.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 13/01/2026.
//

import Foundation

struct BlisterPage: Identifiable, Hashable {
    let id: UUID
    let itemsCount: Int

    init(id: UUID = UUID(), itemsCount: Int) {
        self.id = id
        self.itemsCount = itemsCount
    }
}
