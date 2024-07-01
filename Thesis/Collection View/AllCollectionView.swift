import SwiftUI
import SwiftData

struct AllCollectionView: View {
    // Database
    @Environment(\.modelContext) private var modelContext
    @Query private var collections: [ItemCollection]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var isAlertPresented = false
    @State private var collectionName = ""
    @State private var selectedCollection: ItemCollection = ItemCollection(id: UUID(), name: "", dataURL: "", snapshotItem: Data())
    @State private var ARTapped = false
    
    @State private var importSheet = false
    @State private var importPreview = false
    @State private var usdzURL: URL?
    
    @State private var isObjectCaptureViewPresented = false
    
    // Background Color
    @State var selectedColor = Color.black
    
    // For Light Mode & Dark Mode support
    @Environment(\.colorScheme) var colorScheme
    var textColor: Color {
        if colorScheme == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, content: {
                // Button for import & scan
                Menu {
                    Button {
                        self.importSheet.toggle()
                    } label: {
                        Text("Import from Files")
                    }
                    
                    Button {
                        self.isObjectCaptureViewPresented.toggle()
                    } label: {
                        Text("Scan new object")
                    }
                } label: {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.regularMaterial)
                            Image(systemName: "plus")
                                .resizable()
                                .foregroundStyle(.regularMaterial)
                                .frame(width: 120, height: 120)
                        }
                        .frame(width: 250, height: 200)
                        Text("Add Items")
                            .foregroundStyle(textColor)
                    }
                }
                
                ForEach(collections) { collection in
                    CollectionBoxView(collection: collection, selectedColor: $selectedColor)
                        .padding()
                        .contextMenu(ContextMenu(menuItems: {
                            Button(action: {
                                isAlertPresented.toggle()
                                selectedCollection = collection
                            }, label: {
                                Text("Rename")
                            })
                            Button(role: .destructive) {
                                deleteCollection(selectedCollection: collection)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }))
                }
            })
            
        }
        .alert("New Project Name", isPresented: $isAlertPresented) {
            TextField("Untitled", text: $collectionName)
            Button("OK", action: renameCollection)
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $importSheet) {
            DocumentPicker(importSheet: $importSheet, importPreview: $importPreview, usdzURL: $usdzURL)
        }
        .fullScreenCover(isPresented: $importPreview) {
            ImportedView(usdzURL: $usdzURL)
        }
        
#if !targetEnvironment(simulator)
        .fullScreenCover(isPresented: $isObjectCaptureViewPresented, content: {
            GuidedCaptureView()
        })
#endif
    }
    
    private func deleteCollection(selectedCollection: ItemCollection) {
        withAnimation {
            // Delete USDZ Files
            let fileManager  = FileManager.default
            
            do {
                // Get the documents directory URL
                let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                
                // Construct the file URL using the relative path
                let fileURL = documentsURL.appendingPathComponent(selectedCollection.dataURL)
                
                try fileManager.removeItem(at: fileURL)
                print("Selected collection has been deleted successfully at \(fileURL)")
            } catch {
                print("Could not delete file : \(error.localizedDescription)")
            }
            
            modelContext.delete(selectedCollection)
        }
    }
    
    private func renameCollection() {
        selectedCollection.name = (collectionName != "") ? collectionName : "Untitled"
        
        selectedCollection = ItemCollection(id: UUID(), name: "", dataURL: "", snapshotItem: Data())
        collectionName = ""
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to change name")
        }
    }
}

struct CollectionBoxView: View {
    @Environment(\.colorScheme) var colorScheme

    var textColor: Color {
        if colorScheme == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    var collection: ItemCollection
    
    @State var objectDimensionData = ObjectDimensionData()
    
    @Binding var selectedColor: Color
    
    var body: some View {
        NavigationLink {
            CollectionSceneView(scene: CollectionSceneKitView(collection: collection, objectDimensionData: self.objectDimensionData, selectedColor: $selectedColor), objectDimensionData: self.objectDimensionData, name: collection.name, selectedColor: $selectedColor)
        } label: {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.regularMaterial)
                    Image(uiImage: UIImage(data: collection.snapshotItem)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 246, height: 196)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .frame(width: 250, height: 200)
                Text("\(collection.name)")
                    .foregroundStyle(textColor)
            }
        }
    }
}
