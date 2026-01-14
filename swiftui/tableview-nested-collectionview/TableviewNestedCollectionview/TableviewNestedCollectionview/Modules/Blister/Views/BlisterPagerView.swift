//
//  BlisterPagerView.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 13/01/2026.
//

import SwiftUI

struct BlisterPagerView: View {
    let pages: [BlisterPage]
    @Binding var currentPageID: UUID?

    let onSquareTap: (_ pageID: UUID, _ index: Int) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(pages) { page in
                    BlisterPageCardView(
                        page: page,
                        onSquareTap: { index in onSquareTap(page.id, index) }
                    )
                    .padding(.horizontal, 32)
                    .containerRelativeFrame(.horizontal)
                    .id(page.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $currentPageID)
        .onAppear {
            if currentPageID == nil {
                currentPageID = pages.first?.id
            }
        }
    }
}
