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
    @State private var selectedCollection: ItemCollection = ItemCollection(id: UUID(), name: "", data: Data(), dataURL: "", snapshotItem: Data())
    @State private var ARTapped = false
    
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
                // Button for New Project
//                NavigationLink {
//                    NewProjectSceneView()
//                } label: {
//                    VStack {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 10)
//                                .foregroundStyle(.regularMaterial)
//                            Image(systemName: "plus")
//                                .resizable()
//                                .foregroundStyle(.regularMaterial)
//                                .frame(width: 120, height: 120)
//                        }
//                        .frame(width: 250, height: 200)
//                        Text("New Project")
//                            .foregroundStyle(textColor)
//                    }
//                }
                
                ForEach(collections) { collection in
                    CollectionBoxView(collection: collection)
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
//        .padding()
//        .navigationTitle("All Projects")
//        .toolbar {
//            Button {
//                ARTapped.toggle()
//            } label: {
//                Text("AR")
//            }
//
//            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
//                Text("Edit")
//            })
//        }
//        .navigationBarTitleDisplayMode(.large)
        .alert("New Project Name", isPresented: $isAlertPresented) {
            TextField("Untitled", text: $collectionName)
            Button("OK", action: renameCollection)
            Button("Cancel", role: .cancel) { }
        }
//        .fullScreenCover(isPresented: $ARTapped, content: {
//            ARPageView()
//        })
//        .onAppear {
//            AppDelegate.orientationLock = .landscape
//        }
    }
    
    private func deleteCollection(selectedCollection: ItemCollection) {
        withAnimation {
            modelContext.delete(selectedCollection)
        }
    }
    
    private func renameCollection() {
        selectedCollection.name = (collectionName != "") ? collectionName : "Untitled"
        
        selectedCollection = ItemCollection(id: UUID(), name: "", data: Data(), dataURL: "", snapshotItem: Data())
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
    
    var body: some View {
        NavigationLink {
            CollectionSceneView(collection: collection)
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
