//
//  BlisterPageCardView.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 13/01/2026.
//

import SwiftUI

struct BlisterPageCardView: View {
    let page: BlisterPage
    let onSquareTap: (Int) -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(.secondary.opacity(0.12))
            .overlay {
                BlisterGridView(
                    itemsCount: page.itemsCount,
                    rows: 5,
                    cols: 10,
                    spacing: 6,
                    inset: EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12),
                    onTap: onSquareTap
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
