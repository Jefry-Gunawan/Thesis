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
    @State private var selectedItem: ItemCollection = ItemCollection(id: UUID(), name: "", dataURL: nil, snapshotItem: Data())
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @Binding var activeScene: ScenekitView
    @Binding var itemCollectionOpened: Bool
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.regularMaterial)
                
                ScrollView {
                    LazyVGrid(columns: columns, content: {
                        ForEach(items) { item in
                            ItemBoxView(item: item, activeScene: $activeScene, itemCollectionOpened: $itemCollectionOpened)
                                .contextMenu(ContextMenu(menuItems: {
                                    Button(action: {
                                        isAlertPresented.toggle()
                                        
                                        selectedItem = item
                                    }, label: {
                                        Text("Rename")
                                    })
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
        
        selectedItem = ItemCollection(id: UUID(), name: "", dataURL: nil, snapshotItem: Data())
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
    @Binding var itemCollectionOpened: Bool

    var textColor: Color {
        if colorScheme == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    var body: some View {
        Button {
            let fileManager = FileManager.default
            do {
                // Get the documents directory URL
                let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                
                // Construct the file URL using the relative path
                let fileURL = documentsURL.appendingPathComponent(item.dataURL)
                
                if fileManager.fileExists(atPath: fileURL.path) {
                    print("File exists at URL: \(fileURL)")
                    
                    if let modelasset = try? SCNScene(url: fileURL), let modelNode = modelasset.rootNode.childNodes.first?.clone() {
                        activeScene.view.scene?.rootNode.addChildNode(modelNode)
                        itemCollectionOpened = false
                    }
                } else {
                    print("File does not exist at URL: \(fileURL)")
                }
            } catch {
                print("Error accessing file: \(error)")
            }
        } label: {
            VStack {
                Image(uiImage: UIImage(data: item.snapshotItem)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("\(item.name)")
                    .foregroundStyle(textColor)
            }
        }
        .padding()
    }
}

//#Preview(body: {
//    ItemCollectionView()
//})
