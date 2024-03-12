import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    var view: ARView = ARView(frame: .zero)
    
    func makeUIView(context: Context) -> ARView {
//        view.addCoaching()
        
        // Enable horizontal plane detection
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        
//        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
//            config.sceneReconstruction = .mesh
//        }
        
        view.session.run(config)

        let anchor = AnchorEntity(plane: .horizontal)

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
                if let collisionComponent = modelEntity.components[CollisionComponent.self] as? CollisionComponent {
                    view.installGestures(for: modelEntity)
                }
            }
        }
        

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
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator
    class Coordinator: NSObject {
        var parent: ARViewContainer
        
        var selectedEntity: ModelEntity = ModelEntity()

        init(_ parent: ARViewContainer) {
            self.parent = parent
            super.init()
        }

        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let location = gestureRecognizer.location(in: parent.view)
            
            let hitTests = parent.view.hitTest(location)
            
            if let result = hitTests.first?.entity {
                print("Hit entity found:", result.name)
            } else {
                print("No entity found")
            }
       }
    }
}

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
