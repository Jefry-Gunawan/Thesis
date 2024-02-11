////
////  ARViewContainer.swift
////  Thesis
////
////  Created by Jefry Gunawan on 07/02/24.
////
//
//import SwiftUI
//import SceneKit
//import ARKit
//
//struct ARViewContainer: UIViewRepresentable {
//    let scene: SCNScene
//    let view: SCNView
//
//    func makeUIView(context: Context) -> SCNView {
//        return view
//    }
//
//    func updateUIView(_ uiView: SCNView, context: Context) {
//        // Update the view
//    }
//}
//
//struct ARContentView: View {
//    let scene: SCNScene
//    let view: SCNView
//
//    var body: some View {
//        VStack {
//            ARViewContainer(scene: scene, view: view)
//                .edgesIgnoringSafeArea(.all)
//            Button("View in AR") {
//                openARView()
//            }
//        }
//    }
//    
//    func openARView() {
//        guard let currentFrame = ARView(view).session.currentFrame else {
//            print("Error: Unable to get AR frame.")
//            return
//        }
//        
//        let anchor = AnchorEntity(plane: .horizontal)
//        scene.addAnchor(anchor)
//        
//        // Add the USDZ model to the anchor
//        if let modelURL = Bundle.main.url(forResource: "your_model", withExtension: "usdz") {
//            let modelEntity = try! Entity.load(contentsOf: modelURL)
//            anchor.addChild(modelEntity)
//        } else {
//            print("Error: Unable to load USDZ model.")
//        }
//    }
//}
