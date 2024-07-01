#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
import SwiftUI
import SwiftData
import SceneKit
import RealityKit

struct ImportedView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var textColor: Color {
        if colorScheme == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    @State private var fileName = ""
    @State private var isAlertPresented = false
    
    @State var sceneView: CapturedSceneKitView?
    @Binding var usdzURL: URL?
    
    var body: some View {
        ZStack {
            sceneView
            
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.regularMaterial)
                            Image(systemName: "chevron.left")
                                .foregroundStyle(textColor)
                        }
                    })
                    
                    Spacer()
                }
                Spacer()
                Button(action: {
                    isAlertPresented.toggle()
                }, label: {
                    ZStack {
                        Capsule()
                            .frame(width: 100, height: 50)
                            .foregroundStyle(.regularMaterial)
                        Text("Save")
                            .foregroundStyle(textColor)
                    }
                })
            }
            .padding()
        }
        .alert("Input File Name", isPresented: $isAlertPresented) {
            TextField("Untitled", text: $fileName)
            Button("OK", action: saveToSwiftData)
            Button("Cancel", role: .cancel) { }
        }
        .onAppear {
            self.sceneView = CapturedSceneKitView(usdzURL: self.usdzURL!)
        }
        .onDisappear {
            deleteFileFromTemporaryStorage()
        }
    }
    
    // To clear storage on view disappear
    func deleteFileFromTemporaryStorage() {
        let fileManager = FileManager.default

        if usdzURL != nil {
            do {
                // Check if the file exists
                if fileManager.fileExists(atPath: usdzURL!.path) {
                    // Attempt to remove the file
                    try fileManager.removeItem(at: usdzURL!)
                    print("File deleted successfully.")
                } else {
                    print("File does not exist at path: \(usdzURL!.path)")
                }
            } catch {
                print("Error deleting file: \(error.localizedDescription)")
            }
        }
    }
    
    // To save file in Swift Data & Persistent Storagenya
    func saveToSwiftData() {
        let dataURL = moveFileToPersistentStorage(temporaryURL: usdzURL!)
        
        let snapImage = sceneView!.view.snapshot()
        
        let imageData = snapImage.pngData() ?? Data()
        
        let newItems = ItemCollection(id: UUID(), name: (fileName != "") ? fileName : "Untitled", dataURL: dataURL, snapshotItem: imageData)
                    
        modelContext.insert(newItems)
        
        dismiss()
    }
    
    // Agar file tidak akan hilang ketika iOS melakukan cleanup
    func moveFileToPersistentStorage(temporaryURL: URL) -> String? {
        let fileManager = FileManager.default
        
        do {
            // Get the documents directory URL
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            let uniqueFileName = UUID().uuidString + ".usdz"
            let destinationURL = documentsURL.appendingPathComponent(uniqueFileName)
            
            // Move the file to the persistent storage directory
            try fileManager.moveItem(at: temporaryURL, to: destinationURL)
            
            print("File moved to: \(destinationURL)")
            print("StoredItem saved with URL: \(destinationURL.absoluteString)")
            
            return uniqueFileName
        } catch {
            print("Error moving file: \(error)")
        }
        
        return nil
    }
}
#endif
