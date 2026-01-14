//
//  SquareView.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 13/01/2026.
//

import SwiftUI

struct SquareView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(.tint.opacity(0.25))
            .aspectRatio(1, contentMode: .fit)
            .contentShape(Rectangle())
    }
}
