//
//  HomeView.swift
//  PersistenceSwiftDataTodoList
//
//  Created by Michał Wolanin on 20/02/2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {

    let vm: HomeViewModel
    @Environment(AppRouter.self) private var router

    var body: some View {
        List {
            ForEach(vm.items) { dto in
                HStack(spacing: 12) {
                    Image(systemName: dto.isDone ? "checkmark.circle.fill" : "circle")
                    Text(dto.title)
                        .foregroundStyle(dto.isDone ? .secondary : .primary)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    vm.toggleTask(id: dto.id)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        vm.deleteTask(id: dto.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Todo")
        .toolbar {
            Button {
                router.push(.addTask)
            } label: {
                Image(systemName: "plus")
            }
        }
        .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .onAppear {
            vm.onAppear()
        }
    }
}


#Preview("Home - sample data") {
    let stack = try! SwiftDataStack(inMemory: true)
    let repo = SwiftDataTodoRepository(context: stack.mainContext)

    try? repo.add(title: "Buy milk")
    try? repo.add(title: "Walk dog")
    try? repo.add(title: "Read SwiftData docs")

    let vm = HomeViewModel(repository: repo, context: stack.mainContext)
    let router = AppRouter()

    return NavigationStack {
        HomeView(vm: vm)
    }
    .environment(router)
}
