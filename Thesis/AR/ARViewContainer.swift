#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    var view: ARView = ARView(frame: .zero)
    @State var anchor = AnchorEntity(plane: .horizontal)
    
    @ObservedObject var objectDimensionData: ObjectDimensionData
    
    func makeUIView(context: Context) -> ARView {
//        view.addCoaching()
        
        // Enable horizontal plane detection
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        
//        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
//            config.sceneReconstruction = .mesh
//        }
        
        view.session.run(config)

       // Create a box entity
        let box = MeshResource.generateBox(size: 0.1, cornerRadius: 0.01)

       // Create a material for the box
        let material = SimpleMaterial(color: .red, isMetallic: false)

       // Create a model entity with the box and material
        let boxEntity = ModelEntity(mesh: box, materials: [material])
        boxEntity.position = SIMD3(x: -0.1, y: 0, z: 0)
        boxEntity.name = "Test Cube 1"
        
        let boxEntity2 = ModelEntity(mesh: box, materials: [material])
        boxEntity2.position = SIMD3(x: 0.1, y: 0, z: 0)
        boxEntity2.name = "Test Cube 2"

        anchor.addChild(boxEntity)
        anchor.addChild(boxEntity2)
        
        anchor.name = "Horizontal Plane Anchor"
        anchor.generateCollisionShapes(recursive: true)

       // Add the box entity to the scene
        view.scene.anchors.append(anchor)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        // To add movement gesture
        for tempEntity in anchor.children {
            if let modelEntity = tempEntity as? ModelEntity {
                if modelEntity.components[CollisionComponent.self] is CollisionComponent {
                    view.installGestures(for: modelEntity)
                }
            }
        }
        
        objectDimensionData.reset()

       return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
    // To destroy the old entity and stop the AR from running in the background
    static func dismantleUIView(_ uiView: ARView, coordinator: Coordinator) {
        uiView.session.pause()
        uiView.removeFromSuperview()
        
        for tempEntity in uiView.scene.anchors {
            uiView.scene.anchors.remove(tempEntity)
        }
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
                    
                    var item = try Entity.load(contentsOf: fileURL)
                    
                    // Buat ngambil dari object capture karena namanya selalu mesh
                    if let model = item.findEntity(named: "Mesh") {
                        item = model
                    }
    
                    item.name = name
    
                    anchor.addChild(item)
                    anchor.generateCollisionShapes(recursive: true)
    
                    // To add movement gesture
                    for tempEntity in anchor.children {
                        print("temp \(tempEntity)")
                        if let modelEntity = tempEntity as? ModelEntity {
                            if modelEntity.components[CollisionComponent.self] is CollisionComponent {
                                print("aAa \(modelEntity)")
                                view.installGestures(for: modelEntity)
                            }
                        }
                    }
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
    class Coordinator: NSObject {
        var parent: ARViewContainer

        init(_ parent: ARViewContainer) {
            self.parent = parent
            super.init()
        }

        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let location = gestureRecognizer.location(in: parent.view)
            
            let hitTests = parent.view.hitTest(location)
            
            if let result = hitTests.first?.entity {
                parent.objectDimensionData.selectedEntity = result
                print("Hit entity found:", result.name)
                
                let width = (result.visualBounds(relativeTo: nil).max.x) - (result.visualBounds(relativeTo: nil).min.x)
                let height = (result.visualBounds(relativeTo: nil).max.y) - (result.visualBounds(relativeTo: nil).min.y)
                let length = (result.visualBounds(relativeTo: nil).max.z) - (result.visualBounds(relativeTo: nil).min.z)
//                
                parent.objectDimensionData.name = result.name
                
                parent.objectDimensionData.width = String(format: "%.2f", width)
                parent.objectDimensionData.length = String(format: "%.2f", length)
                parent.objectDimensionData.height = String(format: "%.2f", height)
            } else {
                print("No entity found")
                
                parent.objectDimensionData.reset()
            }
       }
    }
}
#endif

//extension ARView: ARCoachingOverlayViewDelegate {
//    func addCoaching() {
//        
//        let coachingOverlay = ARCoachingOverlayView()
//        coachingOverlay.delegate = self
//        coachingOverlay.session = self.session
//        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        
//        coachingOverlay.goal = .anyPlane
//        self.addSubview(coachingOverlay)
//    }
//    
//    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
//        //Ready to add entities next?
//    }
//}
