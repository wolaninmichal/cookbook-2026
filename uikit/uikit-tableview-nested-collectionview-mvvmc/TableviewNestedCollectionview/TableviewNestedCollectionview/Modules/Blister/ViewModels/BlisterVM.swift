//
//  BlisterVM.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 12/01/2026.
//

import UIKit

final class BlisterVM {
    private(set) var pages: [BlisterPageVM]
    var lastContentOffset: CGPoint = .zero

    init(pages: [BlisterPageVM]) {
        self.pages = pages
    }
}
