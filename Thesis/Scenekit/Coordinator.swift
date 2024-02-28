import Foundation
import SwiftUI
import SceneKit
import QuickLook

class Coordinator: NSObject, UIGestureRecognizerDelegate {
    var parent: ScenekitView
    private var selectedNode: SCNNode?
    
    // 1 = x; 2 = y; 3 = z
    private var selectedMoveAxis: Int = 0
    
    private var lastPanTranslation: CGPoint = .zero
    
    private let untappableList = ["defaultFloor"]
    
    private let moveNodeList = ["moveNode", "moveXNode", "moveYNode", "moveZNode"]
    
    init(parent: ScenekitView) {
        self.parent = parent
        super.init()
        addPanGesture()
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let p = gestureRecognizer.location(in: parent.view)
        let hitResults = parent.view.hitTest(p, options: [:])
        
        resetMoveNode()
        
        if hitResults.count > 0 && !untappableList.contains(hitResults.first?.node.name ?? "") && !moveNodeList.contains(hitResults.first?.node.name ?? "") {
            if let result = hitResults.first {
                print("Result Name : \(result.node.name ?? "")")
                
                selectedNode = result.node
                
                let worldBoundingBox = selectedNode!.boundingBox
                let worldMin = selectedNode!.convertPosition(worldBoundingBox.min, to: nil)
                let worldMax = selectedNode!.convertPosition(worldBoundingBox.max, to: nil)
                
//                print(String(format: "%.2f", worldMax.x - worldMin.x))
//                print(String(format: "%.2f", worldMax.y - worldMin.y))
//                print(String(format: "%.2f", worldMax.z - worldMin.z))
                
                let xFloat = worldMax.x - worldMin.x
                let yFloat = worldMax.y - worldMin.y
                let zFloat = worldMax.z - worldMin.z
                
                parent.moveNodeModel.moveXNode.worldPosition = SCNVector3(0.5 + xFloat/3, 0, 0)
                parent.moveNodeModel.moveYNode.worldPosition = SCNVector3(0, 0.5 + xFloat/3, 0)
                parent.moveNodeModel.moveZNode.worldPosition = SCNVector3(0, 0, 0.5 + xFloat/3)
                
                parent.moveNodeModel.moveNode.worldPosition = result.node.worldPosition
                parent.moveNodeModel.moveNode.isHidden = false
            }
        } else {
            parent.moveNodeModel.moveNode.isHidden = true
        }
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        
        let p = gestureRecognizer.location(in: parent.view)
        let hitResults = parent.view.hitTest(p, options: [.searchMode: SCNHitTestSearchMode.any.rawValue])
        
        if hitResults.count > 0 && !untappableList.contains(hitResults.first?.node.name ?? "") {
            for result in hitResults {
                if moveNodeList.contains(result.node.name ?? "") {
                    print("Move Name : \(result.node.name ?? "")")
                    parent.isEditMode = true
                    
                    switch result.node.name {
                    case "moveXNode":
                        selectedMoveAxis = 1
                        
                        parent.moveNodeModel.moveXNode.scale = SCNVector3(2, 2, 2)
                        parent.moveNodeModel.moveXNode.opacity = 1
                    case "moveYNode":
                        selectedMoveAxis = 2
                        
                        parent.moveNodeModel.moveYNode.scale = SCNVector3(2, 2, 2)
                        parent.moveNodeModel.moveYNode.opacity = 1
                    case "moveZNode":
                        selectedMoveAxis = 3
                        
                        parent.moveNodeModel.moveZNode.scale = SCNVector3(2, 2, 2)
                        parent.moveNodeModel.moveZNode.opacity = 1
                    default:
                        selectedMoveAxis = 0
                    }
                    break
                }
            }
        } else {
            parent.isEditMode = false
        }
        
//        switch gestureRecognizer.state {
//        case .began:
//            
//        case .ended:
//            parent.isEditMode = false
//        default:
//            parent.isEditMode = false
//        }
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard !parent.isEditMode else {
            guard let selectedNode = selectedNode else { return }
                
            let translation = gestureRecognizer.translation(in: parent.view)
            
            if gestureRecognizer.numberOfTouches == 1 {
                var translationDelta = SCNVector3(
                    x: Float(translation.x - lastPanTranslation.x),
                    y: Float(translation.y - lastPanTranslation.y),
                    z: 0
                )

                // Need more fixing
                let (angle, axis) = parent.view.pointOfView!.orientation.toAxisAngle()
                let rotationMatrix = SCNMatrix4MakeRotation(Float(angle), axis.x, axis.y, axis.z)
                
                translationDelta = SCNVector3MultMatrix4(translationDelta, rotationMatrix)
                
                var currentPosition = selectedNode.position
                
                if selectedMoveAxis == 1 {
                    currentPosition.x += translationDelta.x * 0.01
                } else if selectedMoveAxis == 2 {
                    currentPosition.y -= translationDelta.y * 0.01
                } else if selectedMoveAxis == 3 {
                    currentPosition.z += translationDelta.y * 0.01
                }
                
                selectedNode.worldPosition = currentPosition
                parent.moveNodeModel.moveNode.worldPosition = currentPosition
            }
            
            switch gestureRecognizer.state {
                case .began:
                    lastPanTranslation = translation
                case .changed:
                    lastPanTranslation = translation
                default:
                    lastPanTranslation = .zero
                    parent.isEditMode = false
                    selectedMoveAxis = 0
                    resetMoveNodeEffect()
            }
            return
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func resetMoveNode() {
        parent.moveNodeModel.moveNode.worldPosition = SCNVector3(0, 0, 0)
        parent.moveNodeModel.moveXNode.worldPosition = SCNVector3(0.5, 0, 0)
        parent.moveNodeModel.moveYNode.worldPosition = SCNVector3(0, 0.5, 0)
        parent.moveNodeModel.moveZNode.worldPosition = SCNVector3(0, 0, 0.5)
        
        resetMoveNodeEffect()
    }
    
    func resetMoveNodeEffect() {
        parent.moveNodeModel.moveXNode.scale = SCNVector3(1, 1, 1)
        parent.moveNodeModel.moveYNode.scale = SCNVector3(1, 1, 1)
        parent.moveNodeModel.moveZNode.scale = SCNVector3(1, 1, 1)
        
        parent.moveNodeModel.moveXNode.opacity = 0.5
        parent.moveNodeModel.moveYNode.opacity = 0.5
        parent.moveNodeModel.moveZNode.opacity = 0.5
    }
    
    func SCNVector3MultMatrix4(_ vector: SCNVector3, _ matrix: SCNMatrix4) -> SCNVector3 {
        let x = vector.x * matrix.m11 + vector.y * matrix.m21 + vector.z * matrix.m31
        let y = vector.x * matrix.m12 + vector.y * matrix.m22 + vector.z * matrix.m32
        let z = vector.x * matrix.m13 + vector.y * matrix.m23 + vector.z * matrix.m33
        return SCNVector3(x, y, z)
    }
}
