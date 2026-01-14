//
//  BlisterBottomView.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 13/01/2026.
//

import SwiftUI

struct BlisterBottomView: View {
    let model: BlisterBottom

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(model.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
    }
}
