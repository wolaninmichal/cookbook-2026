//
//  BlisterScreen.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 13/01/2026.
//

import SwiftUI

struct BlisterScreen: View {
    @Environment(AppRouter.self) private var router
    @State private var viewModel: BlisterViewModel = .init()

    var body: some View {
        @Bindable var vm = viewModel

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                Text("Blister")
                    .font(.headline)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)

                BlisterPagerView(
                    pages: vm.pages,
                    currentPageID: $vm.currentPageID,
                    onSquareTap: { pageID, index in
                        vm.didTapSquare(pageID: pageID, index: index)
                    }
                )
                .frame(height: 180)

                BlisterBottomView(model: vm.bottom)
            }
        }
        .navigationTitle("swiftui-tableview-nested-collectionview")
        .navigationBarTitleDisplayMode(.inline)
        .background(.background)
        
        /// React to selection and perform routing here (VM stays navigation-agnostic).
        .onChange(of: vm.selection) { _, newValue in
            guard let sel = newValue else { return }
            router.push(.squareDetail(pageID: sel.pageID, index: sel.index))
            vm.selection = nil
        }
    }
}
