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
    @State var searchMoveNodeDone: Bool = false
    
    @ObservedObject var moveNodeModel: MoveNodeModel = MoveNodeModel()
    
    init(loadSceneBool: Bool, loadedProject: Data = Data()) {
        self.loadSceneBool = loadSceneBool
        self.loadedProject = loadedProject
    }
    
    func makeUIView(context: Context) -> some UIView {
        view.scene = scene
        view.allowsCameraControl = !isEditMode
        view.backgroundColor = .black
        
        if loadSceneBool {
            loadScene()
        } else {
            createMoveNode()
            createNew()
        }
        
        // Giving purple warning. Bisa ditaruh di coordinator
        // Should be better here because it initialized in the beginning.
        if !searchMoveNodeDone {
            searchMoveNode()
        }
    
        // Gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        let holdGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPress(_:)))
        holdGesture.minimumPressDuration = 0.2
        view.addGestureRecognizer(holdGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        view.allowsCameraControl = !isEditMode
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func createNew() {
        // Add camera to the scene
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.name = "cameraNode"
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0.75, z: 5) // Initial camera position
        scene.rootNode.addChildNode(cameraNode)

        // Add a point light to the scene
        let light = SCNLight()
        light.type = .omni
        light.intensity = 200
        light.temperature = 6000
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 5, y: 5, z: 10)
        view.scene?.rootNode.addChildNode(lightNode)
        
        let light2 = SCNLight()
        light2.type = .omni
        light.intensity = 300
        light2.temperature = 6000
        let light2Node = SCNNode()
        light2Node.light = light2
        light2Node.position = SCNVector3(x: -5, y: 5, z: -10)
        view.scene?.rootNode.addChildNode(light2Node)
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 100.0
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        view.scene?.rootNode.addChildNode(ambientLightNode)
        
        let floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = UIColor.gray
//        floor.width = 5
//        floor.length = 5
        floor.reflectionFalloffEnd = 0.5
        floor.reflectivity = 0.1
        let floorNode = SCNNode(geometry: floor)
        floorNode.name = "defaultFloor"
        floorNode.position = SCNVector3(x: 0, y: 0, z: 0)
        view.scene?.rootNode.addChildNode(floorNode)
        
        // Test Box
        let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "Box 1"
        boxNode.position = SCNVector3(x: -0.75, y: 0.5, z: 0)
        view.scene?.rootNode.addChildNode(boxNode)
        
        let boxNode2 = SCNNode(geometry: box)
        boxNode2.name = "Box 2"
        boxNode2.position = SCNVector3(x: 0.75, y: 0.5, z: 0)
        view.scene?.rootNode.addChildNode(boxNode2)
        
        // Add Sample Room
//        if let sampleAsset = SCNScene(named: "Sample Room.usdz"),
//           let sampleNode = sampleAsset.rootNode.childNodes.first?.clone() {
//            view.scene?.rootNode.addChildNode(sampleNode)
//        }
        
    }
    
    private func createMoveNode() {
        // Create the geometry
        let coneXGeometry = SCNCone(topRadius: 0, bottomRadius: 0.1, height: 0.2)
        let coneYGeometry = SCNCone(topRadius: 0, bottomRadius: 0.1, height: 0.2)
        let coneZGeometry = SCNCone(topRadius: 0, bottomRadius: 0.1, height: 0.2)
        
        // Fill nodes for X, Y, and Z axes
        let moveXNode = SCNNode(geometry: coneXGeometry)
        let moveYNode = SCNNode(geometry: coneYGeometry)
        let moveZNode = SCNNode(geometry: coneZGeometry)
        
        // Rotate cones to point along respective axes
        moveXNode.eulerAngles = SCNVector3(0, 0, -Float.pi / 2)
        moveYNode.eulerAngles = SCNVector3(0, 0, 0)
        moveZNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        
        // Change color and position
        moveXNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        moveXNode.position = SCNVector3(0.5, 0, 0)
        
        moveYNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        moveYNode.position = SCNVector3(0, 0.5, 0)
        
        moveZNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        moveZNode.position = SCNVector3(0, 0, 0.5)
        
        // Change name
        moveXNode.name = "moveXNode"
        moveYNode.name = "moveYNode"
        moveZNode.name = "moveZNode"
        
        // create parent node biar masuknya jadi 1 node
        let moveNode = SCNNode()
        moveNode.name = "moveNode"
        moveNode.addChildNode(moveXNode)
        moveNode.addChildNode(moveYNode)
        moveNode.addChildNode(moveZNode)
        
        moveXNode.renderingOrder = 1
        moveXNode.geometry?.firstMaterial?.readsFromDepthBuffer = false
        moveXNode.geometry?.firstMaterial?.writesToDepthBuffer = false
        moveXNode.opacity = 0.5
        
        moveYNode.renderingOrder = 1
        moveYNode.geometry?.firstMaterial?.readsFromDepthBuffer = false
        moveYNode.geometry?.firstMaterial?.writesToDepthBuffer = false
        moveYNode.opacity = 0.5
        
        moveZNode.renderingOrder = 1
        moveZNode.geometry?.firstMaterial?.readsFromDepthBuffer = false
        moveZNode.geometry?.firstMaterial?.writesToDepthBuffer = false
        moveZNode.opacity = 0.5
//        moveNode.renderingOrder = 1
//        moveNode.geometry?.firstMaterial?.writesToDepthBuffer = false
//        moveNode.geometry?.firstMaterial?.readsFromDepthBuffer = false
        moveNode.isHidden = true
        self.view.scene?.rootNode.addChildNode(moveNode)
    }
    
    // To fill the move node
    func searchMoveNode() {
        for childNode in view.scene!.rootNode.childNodes {
            if childNode.name == "cameraNode" {
                moveNodeModel.cameraNode = childNode
                break
            }
        }
        
        for childNode in view.scene!.rootNode.childNodes {
            if childNode.name == "moveNode" {
                moveNodeModel.moveNode = childNode
                break
            }
        }
        
        for childNode in moveNodeModel.moveNode.childNodes {
            switch childNode.name {
            case "moveXNode":
                moveNodeModel.moveXNode = childNode
            case "moveYNode":
                moveNodeModel.moveYNode = childNode
            case "moveZNode":
                moveNodeModel.moveZNode = childNode
            default:
                print("Move Axis Node Not Found!!")
            }
        }
        
        searchMoveNodeDone = true
    }
    
    func loadScene() {
        if let scene = try! NSKeyedUnarchiver.unarchivedObject(ofClass: SCNScene.self, from: loadedProject) {
            view.scene = scene
        }
    }
    
    func loadItem(loadedItem: Data) {
        // Kalau nyimpennya pakai SCNNode
        if let loadedNode = try! NSKeyedUnarchiver.unarchivedObject(ofClass: SCNNode.self, from: loadedItem) {
            view.scene?.rootNode.addChildNode(loadedNode)
        }
    }
    
    func saveNewScene() -> Project {
        // Convert SceneKit content to Data
        let sceneData = try? NSKeyedArchiver.archivedData(withRootObject: view.scene!, requiringSecureCoding: true)
        
        let imageData = saveSnapshot()
        
        let projectCount = projects.count
        let newProject = Project(id: UUID(),
                                 name: "Project \(projectCount + 1)",
                                 data: sceneData!,
                                 roomLength: 0,
                                 roomWidth: 0,
                                 snapshotProject: imageData)
        
        return newProject
    }
    
    func saveScenetoExistingProject() -> Data {
        return try! NSKeyedArchiver.archivedData(withRootObject: view.scene!, requiringSecureCoding: true)
    }
    
    func saveSnapshot() -> Data {
        let snapImage = view.snapshot()
        
        return snapImage.pngData() ?? Data()
    }
    
    func export(selector: Int) {
        let exportUSDZ = ExportUSDZ(scene: self.view.scene!, view: self.view, usdzURL: self.usdzURL)
        exportUSDZ.exportNodeToUSDZ(selector: selector)
    }
}

extension SCNQuaternion {
    func toAxisAngle() -> (angle: CGFloat, axis: SCNVector3) {
        let angle = 2 * acos(w)
        let denom = sqrt(1 - w * w)
        let axis = denom > 0.0001 ? SCNVector3(x / denom, y / denom, z / denom) : SCNVector3(1, 0, 0)
        return (CGFloat(angle), axis)
    }
}
