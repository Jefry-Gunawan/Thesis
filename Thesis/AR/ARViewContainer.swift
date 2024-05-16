#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    var view: ARView = ARView(frame: .zero)
    @State var anchor = AnchorEntity(plane: .horizontal)
    @State var textEntity: Entity?
    
    @ObservedObject var objectDimensionData: ObjectDimensionData
    
    @Binding var rulerMode: Bool
    @Binding var rulerDistance: String?
    
    @State var rulerAnchor: [AnchorEntity] = []
    
    func makeUIView(context: Context) -> ARView {
//        view.addCoaching()
        
        // Enable horizontal plane detection
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .meshWithClassification
        }
        
        view.session.run(config)

       // Create a box entity
        let box = MeshResource.generateBox(size: 0.1, cornerRadius: 0.01)

       // Create a material for the box
        let material = SimpleMaterial(color: .red, isMetallic: false)

       // Create a model entity with the box and material
//        let boxEntity = ModelEntity(mesh: box, materials: [material])
//        boxEntity.position = SIMD3(x: -0.1, y: 0, z: 0)
//        boxEntity.name = "Test Cube 1"
//        
//        let boxEntity2 = ModelEntity(mesh: box, materials: [material])
//        boxEntity2.position = SIMD3(x: 0.1, y: 0, z: 0)
//        boxEntity2.name = "Test Cube 2"

//        anchor.addChild(boxEntity)
//        anchor.addChild(boxEntity2)
        
        anchor.name = "Horizontal Plane Anchor"
        anchor.generateCollisionShapes(recursive: true)

       // Add anchor to the scene
        view.scene.anchors.append(anchor)
        
//        let text = MeshResource.generateText("Test", extrusionDepth: 0.0005, font: .systemFont(ofSize: 0.025), containerFrame: CGRect.zero, alignment: .center, lineBreakMode: .byTruncatingTail)
//        let textMaterial = SimpleMaterial(color: .green, isMetallic: false)
//        let textEntity = ModelEntity(mesh: text, materials: [textMaterial])
//        textEntity.position = [-0.1, 0.0, 0]
//        anchor.addChild(textEntity)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        // To add movement gesture
        for tempEntity in anchor.children {
            if let modelEntity = tempEntity as? ModelEntity {
                if modelEntity.components[CollisionComponent.self] is CollisionComponent {
                    view.installGestures([.translation, .rotation], for: modelEntity)
                }
            }
        }
        
        anchor.generateCollisionShapes(recursive: true)
        objectDimensionData.reset()

       return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        if !self.rulerMode {
            for temp in self.rulerAnchor {
                temp.removeFromParent()
            }
            self.rulerAnchor.removeAll()
            self.rulerDistance = nil
        }
    }
    
    // To destroy the old entity and stop the AR from running in the background
    static func dismantleUIView(_ uiView: ARView, coordinator: Coordinator) {
        uiView.session.pause()
        uiView.removeFromSuperview()
        
        for tempEntity in uiView.scene.anchors {
            uiView.scene.anchors.remove(tempEntity)
        }
    }
    
    func findModelEntities(in entity: Entity) -> [ModelEntity] {
        var modelEntities: [ModelEntity] = []
        
        for child in entity.children {
            if let modelEntity = child as? ModelEntity {
                // Found a ModelEntity
                modelEntities.append(modelEntity)
            } else if let subEntity = child as? Entity {
                // Recursively search within sub-entities
                let subModelEntities = findModelEntities(in: subEntity)
                modelEntities.append(contentsOf: subModelEntities)
            }
        }
        
        return modelEntities
    }
    
    func addItem(name: String, dataURL: String) {
        let fileManager = FileManager.default
            do {
                // Get the documents directory URL
                let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                
                // Construct the file URL using the relative path
                let fileURL = documentsURL.appendingPathComponent(dataURL)
                
                if fileManager.fileExists(atPath: fileURL.path) {
                    print("File exists at URL: \(fileURL)")
                    
                    let item = try Entity.load(contentsOf: fileURL)
                    
                    // Cari yang model entity secara recursive
                    let modelEntities = findModelEntities(in: item)
                               
                    for modelEntity in modelEntities {
                        modelEntity.name = name
                       
                        anchor.addChild(modelEntity)
                        anchor.generateCollisionShapes(recursive: true)
                       
                        view.installGestures([.translation, .rotation], for: modelEntity)
                    }
                    
//                    // Buat ngambil dari object capture karena namanya selalu mesh
//                    if let model = item.findEntity(named: "Mesh") {
//                        item = model
//                    }
//
//                    item.name = name
//    
//                    anchor.addChild(item)
//                    anchor.generateCollisionShapes(recursive: true)
//    
//                    // To add movement gesture
//                    for tempEntity in anchor.children {
//                        if let modelEntity = tempEntity as? ModelEntity {
//                            if modelEntity.components[CollisionComponent.self] is CollisionComponent {
//                                view.installGestures([.translation, .rotation], for: modelEntity)
//                            }
//                        }
//                    }
                } else {
                    print("File does not exist at URL: \(fileURL)")
                }
            } catch {
                print("Error accessing file: \(error)")
            }
    }
    
    func removeEntity() {
        if (self.objectDimensionData.selectedEntity != nil) {
            self.anchor.removeChild(self.objectDimensionData.selectedEntity!)
            self.objectDimensionData.reset()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: ARViewContainer
        private var lastPanTranslation: CGPoint = .zero

        init(_ parent: ARViewContainer) {
            self.parent = parent
            super.init()
            addPanGesture()
        }

        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let location = gestureRecognizer.location(in: parent.view)
            
            // If in ruler mode
            if parent.rulerMode {
                if let result = parent.view.raycast(from: location, allowing: .estimatedPlane, alignment: .any).first {
                    let pos = result.worldTransform
                    
                    if parent.rulerAnchor.count >= 2 {
                        for temp in parent.rulerAnchor {
                            temp.removeFromParent()
                        }
                        parent.rulerAnchor.removeAll()
                        parent.rulerDistance = nil
                    }
                    
                    let sphereAnchor = AnchorEntity(world: pos)
                    let sphere = ModelEntity(mesh: .generateSphere(radius: 0.005), materials: [SimpleMaterial(color: .red, isMetallic: false)])
//                    sphere.position.y = 0.01
                    sphereAnchor.addChild(sphere)
                    parent.rulerAnchor.append(sphereAnchor)
                    parent.view.scene.addAnchor(sphereAnchor)
                    
                    if parent.rulerAnchor.count == 2 {
                        let entity1 = parent.rulerAnchor[0]
                        let entity2 = parent.rulerAnchor[1]
                        let position1 = entity1.position(relativeTo: nil)
                        let position2 = entity2.position(relativeTo: nil)
                        
                        let distance = simd_distance(position1, position2)
                        parent.rulerDistance = String(format: "%.2f", distance)
                        
                        let midPosition = SIMD3<Float>(x:(position1.x + position2.x) / 2,
                                                    y:(position1.y + position2.y) / 2,
                                                    z:(position1.z + position2.z) / 2)
                        let lineAnchor = AnchorEntity()
                        lineAnchor.position = midPosition

                        lineAnchor.look(at: position1, from: midPosition, relativeTo: nil)


                        let meters = simd_distance(position1, position2)

                        let lineMaterial = SimpleMaterial.init(color: .red, roughness: 1, isMetallic: false)
                        let bottomLineMesh = MeshResource.generateBox(width:0.001,
                                                              height: 0.001,
                                                              depth: meters)

                        let bottomLineEntity = ModelEntity(mesh: bottomLineMesh, materials: [lineMaterial])

                        bottomLineEntity.position = .init(0, 0, 0)
                        lineAnchor.addChild(bottomLineEntity)
                        parent.rulerAnchor.append(lineAnchor)

                        parent.view.scene.addAnchor(lineAnchor)
                    }
                }
                return
            }
            
            let hitTests = parent.view.entities(at: location)
            
            if let result = hitTests.first {
                parent.objectDimensionData.selectedEntity = result
                print("Hit entity found:", result.name)
                
                // Delete text entity to make sure size stays the same
                if parent.textEntity != nil {
                    parent.textEntity?.removeFromParent()
                }
                
                let temp = result.clone(recursive: true)
                temp.transform.rotation = simd_quatf(real: 0, imag: SIMD3<Float>(0, 0, 0))
                
                let size = temp.visualBounds(relativeTo: nil)
                let width = size.extents.x
                let height = size.extents.y
                let length = size.extents.z
                
                parent.objectDimensionData.name = result.name
                
                parent.objectDimensionData.width = String(format: "%.2f", width)
                parent.objectDimensionData.length = String(format: "%.2f", length)
                parent.objectDimensionData.height = String(format: "%.2f", height)
                
                // Text
                if parent.textEntity != nil {
                    parent.textEntity?.removeFromParent()
                }
                
                let text = MeshResource.generateText(result.name, extrusionDepth: 0.0005, font: .systemFont(ofSize: 0.25 * CGFloat(width)), containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping)
                let textMaterial = UnlitMaterial(color: .green)
                let textEntity = ModelEntity(mesh: text, materials: [textMaterial])
//                textEntity.position = result.position(relativeTo: parent.anchor)
                textEntity.position.y = height
                textEntity.position.x -= width / 2
                parent.textEntity = textEntity
                print(textEntity.position)
                
                result.addChild(textEntity)
            } else {
                print("No entity found")
                
                if parent.textEntity != nil {
                    parent.textEntity?.removeFromParent()
                }
                
                parent.objectDimensionData.reset()
            }
       }
        
        @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
            if gestureRecognizer.numberOfTouches == 2 {
                let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
                guard let selectedEntity = parent.objectDimensionData.selectedEntity else { return }
                
                // To make sure it returns to normal state. Cause for some reason statenya wont become .ended
                if gestureRecognizer.state == .began {
                    lastPanTranslation = .zero
                }
                
                let translationDelta = (
                    x: Float(translation.x - lastPanTranslation.x),
                    y: Float(translation.y - lastPanTranslation.y),
                    z: Float(translation.x - lastPanTranslation.x)
                )
                
                var currentPosition = selectedEntity.position
                
                currentPosition.y -= translationDelta.y * 0.005
                selectedEntity.position = currentPosition

                switch gestureRecognizer.state {
                case .began:
                    lastPanTranslation = translation
                case .changed:
                    lastPanTranslation = translation
                default:
                    lastPanTranslation = .zero
                }
            }
        }
        
        func addPanGesture() {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            panGesture.delegate = self
            parent.view.addGestureRecognizer(panGesture)
        }
        
        func removePanGesture() {
            if let gestureRecognizers = parent.view.gestureRecognizers {
                for gesture in gestureRecognizers {
                    if gesture is UIPanGestureRecognizer {
                        parent.view.removeGestureRecognizer(gesture)
                    }
                }
            }
        }
    }
}
#endif
