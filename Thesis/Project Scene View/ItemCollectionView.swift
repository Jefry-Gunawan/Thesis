//
//  ItemCollectionView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 11/02/24.
//

import Foundation
import SwiftUI
import SwiftData
import SceneKit

struct ItemCollectionView: View {
    // Database
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ItemCollection]
    
    @State private var isAlertPresented = false
    @State private var fileName = ""
    @State private var selectedItem: ItemCollection = ItemCollection(id: UUID(), name: "", data: Data())
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @Binding var activeScene: ScenekitView
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.regularMaterial)
                
                ScrollView {
                    LazyVGrid(columns: columns, content: {
                        ForEach(items) { item in
                            ItemBoxView(item: item, activeScene: $activeScene)
                                .contextMenu(ContextMenu(menuItems: {
                                    Button(action: {
                                        isAlertPresented.toggle()
                                        
                                        selectedItem = item
                                    }, label: {
                                        Text("Rename")
                                    })
//                                    Button(action: {
//                                        deleteItem(selectedItem: item)
//                                    }, label: {
//                                        Text("Delete")
//                                    })
                                    Button(role: .destructive) {
                                        deleteItem(selectedItem: item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }))
                        }
                    })
                }
                .frame(width: 600, height: 600)
                .clipped()
            }
            .frame(width: 600, height: 600)
        }
        .alert("Input File Name", isPresented: $isAlertPresented) {
            TextField("Untitled", text: $fileName)
            Button("OK", action: renameItem)
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func deleteItem(selectedItem: ItemCollection) {
        withAnimation {
            modelContext.delete(selectedItem)
        }
    }
    
    private func renameItem() {
        selectedItem.name = (fileName != "") ? fileName : "Untitled"
        
        selectedItem = ItemCollection(id: UUID(), name: "", data: Data())
        fileName = ""
        do {
            try modelContext.save()
        } catch {
            print("Failed to change name")
        }
    }
}

struct ItemBoxView: View {
    @Environment(\.colorScheme) var colorScheme
    var item: ItemCollection
    @Binding var activeScene: ScenekitView

    var textColor: Color {
        if colorScheme == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    var body: some View {
        Button {
            if let loadedNode = try! NSKeyedUnarchiver.unarchivedObject(ofClass: SCNNode.self, from: item.data) {
                activeScene.view.scene?.rootNode.addChildNode(loadedNode)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.regularMaterial)
                Text("\(item.name)")
                    .foregroundStyle(textColor)
            }
        }
        .frame(width: 150, height: 150)
        .padding()
    }
}

//#Preview(body: {
//    ItemCollectionView()
//})
