//
//  SceneView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 30/01/24.
//

import SceneKit
import SwiftUI
import SwiftData

struct ScenekitView: UIViewRepresentable {
    // Database
    @Query private var projects: [Project]
    
    var loadSceneBool: Bool
    var loadedProject: Data = Data()
    
    var scene = SCNScene()
    var view = SCNView()
    var usdzURL: URL?
    
    @State var isEditMode: Bool = false
    
    func makeUIView(context: Context) -> some UIView {
        view.scene = scene
        view.showsStatistics = true
        view.allowsCameraControl = !isEditMode
        view.backgroundColor = .black
        
        if loadSceneBool {
            loadScene()
        } else {
            createNew()
        }
        
        // Gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        view.allowsCameraControl = !isEditMode
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func createNew() {
        // Add camera to the scene
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5) // Initial camera position
        scene.rootNode.addChildNode(cameraNode)

        // Add a point light to the scene
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 5, y: 5, z: 10)
        view.scene?.rootNode.addChildNode(lightNode)
        
        let light2 = SCNLight()
        light.type = .omni
        let light2Node = SCNNode()
        light2Node.light = light2
        light2Node.position = SCNVector3(x: -5, y: 5, z: -10)
        view.scene?.rootNode.addChildNode(light2Node)

        // Test Box
        let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "Box 1"
        boxNode.position = SCNVector3(x: -0.75, y: 0, z: 0)
        scene.rootNode.addChildNode(boxNode)
        
        let boxNode2 = SCNNode(geometry: box)
        boxNode2.name = "Box 2"
        boxNode2.position = SCNVector3(x: 0.75, y: 0, z: 0)
        scene.rootNode.addChildNode(boxNode2)
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 100.0
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    func loadScene() {
        if let scene = try! NSKeyedUnarchiver.unarchivedObject(ofClass: SCNScene.self, from: loadedProject) {
            view.scene = scene
        }
    }
    
    func saveNewScene() -> Project {
        // Convert SceneKit content to Data
        let sceneData = try? NSKeyedArchiver.archivedData(withRootObject: view.scene!, requiringSecureCoding: true)
//        sceneData.setValue(sceneData, forKeyPath: "sceneContent")
        
        let projectCount = projects.count
        let newProject = Project(id: UUID(),
                                 name: "Project \(projectCount + 1)",
                                 data: sceneData!,
                                 roomLength: 0,
                                 roomWidth: 0)
        
        return newProject
    }
    
    func saveScenetoExistingProject() -> Data {
        return try! NSKeyedArchiver.archivedData(withRootObject: view.scene!, requiringSecureCoding: true)
    }
    
    func export(selector: Int) {
        let exportUSDZ = ExportUSDZ(scene: self.view.scene!, view: self.view, usdzURL: self.usdzURL)
        exportUSDZ.exportNodeToUSDZ(selector: selector)
    }
}
