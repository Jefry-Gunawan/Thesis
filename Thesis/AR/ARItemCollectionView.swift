//
//  ARItemCollectionView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 29/02/24.
//

#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
import SwiftUI
import SwiftData
import SceneKit
import RealityKit

struct ARItemCollectionView: View {
    // Database
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ItemCollection] //Item Collection in SCNNode. Need to convert to AR ModelEntity
    
    @State private var isAlertPresented = false
    @State private var fileName = ""
    @State private var selectedItem: ItemCollection = ItemCollection(id: UUID(), name: "", data: Data(), dataURL: nil, snapshotItem: Data())
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @Binding var activeARView: ARViewContainer
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
                            ARItemBoxView(item: item, activeARView: $activeARView, itemCollectionOpened: $itemCollectionOpened)
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
        
        selectedItem = ItemCollection(id: UUID(), name: "", data: Data(), dataURL: nil, snapshotItem: Data())
        fileName = ""
        do {
            try modelContext.save()
        } catch {
            print("Failed to change name")
        }
    }
}

struct ARItemBoxView: View {
    @Environment(\.colorScheme) var colorScheme
    var item: ItemCollection
    @Binding var activeARView: ARViewContainer
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
            activeARView.addItem(name: item.name, dataURL: item.dataURL)
            itemCollectionOpened = false
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
#endif
