//
//  CapturedObjectView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 12/02/24.
//

#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
import SwiftUI
import SwiftData
import SceneKit

struct CapturedObjectView: View {
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
    
    @State var sceneView: CapturedSceneKitView
    var usdzURL: URL
    let endCaptureCallback: () -> Void
    
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
    .onDisappear {
            endCaptureCallback()
        }
    }
    
    func saveToSwiftData() {
//        let session = URLSession.shared
//        let task = session.dataTask(with: usdzURL) { (data, response, error) in
//            guard let data = data, error == nil else {
//                print("Failed to fetch data: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            
//            let newItems = ItemCollection(id: UUID(), name: (fileName != "") ? fileName : "Untitled", data: data)
//            
//            modelContext.insert(newItems)
//        }
//        
//        task.resume()
        
        // Coba simpan Nodenya
        if let modelasset = try? SCNScene(url: usdzURL), let modelNode = modelasset.rootNode.childNodes.first?.clone() {
            let data = try! NSKeyedArchiver.archivedData(withRootObject: modelNode, requiringSecureCoding: true)
            
            let newItems = ItemCollection(id: UUID(), name: (fileName != "") ? fileName : "Untitled", data: data)
            
            modelContext.insert(newItems)
        }
        
        dismiss()
    }
}
#endif
