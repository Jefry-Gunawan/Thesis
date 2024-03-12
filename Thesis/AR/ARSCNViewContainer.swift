//import SwiftUI
//import ARKit
//import SceneKit
//
//struct ARSCNViewContainer: UIViewRepresentable {
//    var view = ARSCNView(frame: .zero)
//    @State var anchorNode = SCNNode()
//    @State var initialNode = SCNNode()
//    
//    func makeUIView(context: Context) -> ARSCNView {
//        let scene = SCNScene()
//        view.scene = scene
//        
//        view.automaticallyUpdatesLighting = true
//        
//        // Enable horizontal plane detection
//        let config = ARWorldTrackingConfiguration()
//        config.planeDetection = [.horizontal]
//        config.isAutoFocusEnabled = true
//        
//        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
//            config.sceneReconstruction = .mesh
//        }
//        
//        // Add a point light to the scene
//        let light = SCNLight()
//        light.type = .omni
////        light.intensity = 200
////        light.temperature = 5000
//        let lightNode = SCNNode()
//        lightNode.light = light
//        lightNode.position = SCNVector3(x: 5, y: 5, z: 10)
//        view.scene.rootNode.addChildNode(lightNode)
//        
//        let light2 = SCNLight()
//        light2.type = .omni
////        light.intensity = 300
////        light2.temperature = 5000
//        let light2Node = SCNNode()
//        light2Node.light = light2
//        light2Node.position = SCNVector3(x: -5, y: 5, z: -10)
//        view.scene.rootNode.addChildNode(light2Node)
//        
//        let ambientLight = SCNLight()
//        ambientLight.type = .ambient
//        ambientLight.intensity = 100.0
//        let ambientLightNode = SCNNode()
//        ambientLightNode.light = ambientLight
//        view.scene.rootNode.addChildNode(ambientLightNode)
//
//        view.session.run(config)
//
//        // Create test box geometry
//        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red
//        box.materials = [material]
//        
//        let boxNode1 = SCNNode(geometry: box)
//        boxNode1.position = SCNVector3(-0.1, 0, 0)
//        boxNode1.name = "Test Cube 1"
//        
//        let boxNode2 = SCNNode(geometry: box)
//        boxNode2.position = SCNVector3(0.1, 0, 0)
//        boxNode2.name = "Test Cube 2"
//
//        // Create an anchor node
//        initialNode.name = "Horizontal Anchor Node"
//        initialNode.addChildNode(boxNode1)
//        initialNode.addChildNode(boxNode2)
//        
//        // Add the anchor node to the scene
////        view.scene.rootNode.addChildNode(initialNode)
//        
//        // Add tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
//        view.addGestureRecognizer(tapGesture)
//        
//        // Add pan gesture recognizer
//        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
//        view.addGestureRecognizer(panGesture)
//
//        return view
//    }
//
//    func updateUIView(_ uiView: ARSCNView, context: Context) {
//        
//    }
//    
//    static func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
//        uiView.session.pause()
//        uiView.removeFromSuperview()
//        
//        // Remove all nodes from the scene
//        uiView.scene.rootNode.enumerateChildNodes { (node, _) in
//            node.removeFromParentNode()
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, ARSCNViewDelegate {
//        var parent: ARSCNViewContainer
//        var changeAnchorNodePosition = false
//        
//        private var selectedNode: SCNNode?
//        private var lastPanTranslation: CGPoint = .zero
//        
//        init(_ parent: ARSCNViewContainer) {
//            self.parent = parent
//            super.init()
//            parent.view.delegate = self
//        }
//        
//        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//            // Check if the detected anchor is a horizontal plane anchor
//            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//            
//            if changeAnchorNodePosition { return }
//            parent.anchorNode = node
//            
////            parent.initialNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
//            parent.anchorNode.addChildNode(parent.initialNode)
//            
//            changeAnchorNodePosition = true
//        }
//
//        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
//            let location = gestureRecognizer.location(in: parent.view)
//            if let hitResult = parent.view.hitTest(location, options: nil).first {
//                print("Hit entity found:", hitResult.node.name ?? "Unnamed Node")
//                selectedNode = hitResult.node
//            } else {
//                print("No entity found")
//            }
//        }
//        
//        @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
//            guard let selectedNode = selectedNode else { return }
//            let translation = gestureRecognizer.translation(in: parent.view)
//            
//            if gestureRecognizer.numberOfTouches == 1 {
//                var translationDelta = SCNVector3(
//                    x: Float(translation.x - lastPanTranslation.x),
//                    y: Float(translation.y - lastPanTranslation.y),
//                    z: Float(translation.x - lastPanTranslation.x)
//                )
//
////                // Calculate rotation
////                let pointOfView = parent.view.pointOfView!
////                let (angle, axis) = pointOfView.orientation.toAxisAngle()
////                let rotationMatrix = SCNMatrix4MakeRotation(Float(angle), axis.x, axis.y, axis.z)
////                
////                // Transform translationDelta into the object's local coordinate system
////                translationDelta = SCNVector3MultMatrix4(translationDelta, rotationMatrix)
//
//                // Apply translation to the selectedNode's position
//                var currentPosition = selectedNode.position
//                
//                currentPosition.x += translationDelta.x * 0.001
//                currentPosition.z += translationDelta.y * 0.001
//                
//                selectedNode.position = currentPosition
//            }
//            
//            switch gestureRecognizer.state {
//                case .began:
//                    lastPanTranslation = translation
//                case .changed:
//                    lastPanTranslation = translation
//                default:
//                    lastPanTranslation = .zero
//            }
//            return
//        }
//        
//        func SCNVector3MultMatrix4(_ vector: SCNVector3, _ matrix: SCNMatrix4) -> SCNVector3 {
//            let x = vector.x * matrix.m11 + vector.y * matrix.m21 + vector.z * matrix.m31
//            let y = vector.x * matrix.m12 + vector.y * matrix.m22 + vector.z * matrix.m32
//            let z = vector.x * matrix.m13 + vector.y * matrix.m23 + vector.z * matrix.m33
//            return SCNVector3(x, y, z)
//        }
//    }
//}
