//
//  SquareDetailView.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 13/01/2026.
//

import SwiftUI

struct SquareDetailView: View {
    let pageID: UUID
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Square detail")
                .font(.title2).bold()

            Text("pageID: \(pageID.uuidString)")
                .font(.footnote)
                .textSelection(.enabled)

            Text("index: \(index)")
                .font(.body)

            Spacer()
        }
        .padding(16)
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .background(.background)
    }
}
