////
////  ContentView.swift
////  Thesis
////
////  Created by Jefry Gunawan on 30/01/24.
////
//
//import SwiftUI
//import SwiftData
//
//struct ContentViewSwiftData: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var projects: [Project]
//    @Query private var testers: [Tester]
//
//    var body: some View {
//        NavigationSplitView {
//            List {
//                ForEach(projects) { project in
//                    NavigationLink {
//                        Text("Project at \(project.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(project.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Project(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(projects[index])
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//        .modelContainer(for: Project.self, inMemory: true)
//}
