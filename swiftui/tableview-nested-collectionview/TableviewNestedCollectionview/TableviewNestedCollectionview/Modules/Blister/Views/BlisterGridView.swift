//
//  BlisterGridView.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 13/01/2026.
//

import SwiftUI

struct BlisterGridView: View {
    let itemsCount: Int
    let rows: Int
    let cols: Int
    let spacing: CGFloat
    let inset: EdgeInsets
    let onTap: (Int) -> Void

    var body: some View {
        GeometryReader { geo in
            let availableWidth = geo.size.width - (inset.leading + inset.trailing)
            let totalSpacing = CGFloat(max(cols - 1, 0)) * spacing
            let rawSide = (availableWidth - totalSpacing) / CGFloat(cols)
            let side = floor(rawSide)

            if side >= 1 {
                let columns = Array(
                    repeating: GridItem(.fixed(side), spacing: spacing),
                    count: cols
                )

                let visibleCount = min(itemsCount, rows * cols)

                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(0..<visibleCount, id: \.self) { index in
                        SquareView()
                            .onTapGesture { onTap(index) }
                    }
                }
                .padding(inset)
            } else {
                Color.clear
            }
        }
    }
}
