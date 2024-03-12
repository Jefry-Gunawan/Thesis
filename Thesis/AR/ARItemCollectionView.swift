//
//  ARItemCollectionView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 29/02/24.
//


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
    @State private var selectedItem: ItemCollection = ItemCollection(id: UUID(), name: "", data: Data(), entityData: Data())
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @Binding var activeARView: ARViewContainer
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.regularMaterial)
                
                ScrollView {
                    LazyVGrid(columns: columns, content: {
                        ForEach(items) { item in
                            ARItemBoxView(item: item, activeARView: $activeARView)
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
        
        selectedItem = ItemCollection(id: UUID(), name: "", data: Data(), entityData: Data())
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
//                activeARView.view.scene?.rootNode.addChildNode(loadedNode)
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
    
//    func convertMaterial(_ material: SCNMaterial) -> SimpleMaterial {
//        var rMaterial = SimpleMaterial()
//
//        // Handle base color
//        if let baseColorContents = material.diffuse.contents {
//            if let baseColor = baseColorContents as? UIColor {
//                rMaterial.color = .color(baseColor)
//            } else if let baseColorMap = baseColorContents as? UIImage {
//                rMaterial.color = .texture(TextureResource.load(image: baseColorMap))
//            }
//        }
//
//        // Handle other material properties similarly...
//        
//        return rMaterial
//    }
//
//    // Convert SceneKit node to RealityKit entity recursively
//    func convertToEntity(from node: SCNNode) -> ModelEntity? {
//        let entity = ModelEntity()
//
//        // Set the mesh if available
//        if let geometry = node.geometry {
//            let mesh = MeshResource.generate(from: geometry)
//            entity.components.set(ModelComponent(mesh: mesh, materials: geometry.materials.map(convertMaterial)))
//        }
//
//        // Set the transform
//        entity.transform = Transform(matrix: simd_float4x4(node.transform))
//
//        // Convert child nodes
//        for childNode in node.childNodes {
//            if let childEntity = convertToEntity(from: childNode) {
//                entity.addChild(childEntity)
//            }
//        }
//
//        return entity
//    }
}
