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
    
    private let moveNodeList = ["moveNode", "moveXNode", "moveYNode", "moveZNode", "moveRotationNode"]
    
    init(parent: ScenekitView) {
        self.parent = parent
        super.init()
        addPanGesture()
    }
    
    // Handle Tap Gesture
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let p = gestureRecognizer.location(in: parent.view)
        let hitResults = parent.view.hitTest(p, options: [:])
        
        resetMoveNode()
        
        // To make sure system node cant be hit
        if hitResults.count > 0 && !untappableList.contains(hitResults.first?.node.name ?? "") && !moveNodeList.contains(hitResults.first?.node.name ?? "") {
            if let result = hitResults.first {
                print("Result Name : \(result.node.name ?? "")")
                
                selectedNode = result.node
                parent.objectDimensionData.selectedNode = result.node
                
                // To get result that won't be broken by rotation thingy
                let tempNode = selectedNode?.clone()
                tempNode?.eulerAngles.y = 0
                
                let worldBoundingBox = tempNode!.boundingBox
                let worldMin = tempNode!.convertPosition(worldBoundingBox.min, to: nil)
                let worldMax = tempNode!.convertPosition(worldBoundingBox.max, to: nil)
                
                // Get width length height
                let width = worldMax.x - worldMin.x
                let height = worldMax.y - worldMin.y
                let length = worldMax.z - worldMin.z
                
                parent.moveNodeModel.moveXNode.worldPosition = SCNVector3(0.5 + width/3, 0, 0)
                parent.moveNodeModel.moveYNode.worldPosition = SCNVector3(0, 0.5 + height/3, 0)
                parent.moveNodeModel.moveZNode.worldPosition = SCNVector3(0, 0, 0.5 + length/3)
                
                parent.moveNodeModel.moveRotationNode.scale = SCNVector3(max(0.5, width * 0.75), max(0.5, height * 0.75), max(0.5, length * 0.75))
                
                // Change dimension status
                parent.objectDimensionData.name = result.node.name ?? "Untitled"
                parent.objectDimensionData.width = String(format: "%.2f", width)
                parent.objectDimensionData.height = String(format: "%.2f", height)
                parent.objectDimensionData.length = String(format: "%.2f", length)
                
                parent.moveNodeModel.moveNode.worldPosition = result.node.worldPosition
                parent.moveNodeModel.moveNode.isHidden = false
            }
        } else {
            parent.moveNodeModel.moveNode.isHidden = true
            parent.objectDimensionData.reset()
        }
    }
    
    // Handle long press to get move node
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        
        let p = gestureRecognizer.location(in: parent.view)
        let hitResults = parent.view.hitTest(p, options: [.searchMode: SCNHitTestSearchMode.any.rawValue])
        
        // Only applicable to move node
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
                    case "moveRotationNode":
                        selectedMoveAxis = 4
                        
                        parent.moveNodeModel.moveRotationNode.opacity = 1
                    default:
                        selectedMoveAxis = 0
                    }
                    break
                }
            }
        } else {
            parent.isEditMode = false
        }
    }
    
    // Handle pan gesture
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard !parent.isEditMode else {
            guard let selectedNode = selectedNode else { return }
                
            let translation = gestureRecognizer.translation(in: parent.view)
            
            if gestureRecognizer.numberOfTouches == 1 {
                var translationDelta = SCNVector3(
                    x: Float(translation.x - lastPanTranslation.x),
                    y: Float(translation.y - lastPanTranslation.y),
                    z: Float(translation.x - lastPanTranslation.x)
                )

                // Calculate rotation
                let pointOfView = parent.view.pointOfView!
                let (angle, axis) = pointOfView.orientation.toAxisAngle()
                let rotationMatrix = SCNMatrix4MakeRotation(Float(angle), axis.x, axis.y, axis.z)
                
                // Transform translationDelta into the object's local coordinate system
                translationDelta = SCNVector3MultMatrix4(translationDelta, rotationMatrix)

                // Apply translation to the selectedNode's position
                var currentPosition = selectedNode.position
                
                if selectedMoveAxis == 1 {
                    currentPosition.x += translationDelta.x * 0.01
                } else if selectedMoveAxis == 2 {
                    currentPosition.y -= translationDelta.y * 0.01
                } else if selectedMoveAxis == 3 {
                    currentPosition.z += translationDelta.z * 0.01
                } else if selectedMoveAxis == 4 {
                    let rotationAngle = Float(translation.x - lastPanTranslation.x) * 0.01
                    selectedNode.eulerAngles.y += rotationAngle
                }
                
                selectedNode.worldPosition = currentPosition
                parent.moveNodeModel.moveNode.worldPosition = currentPosition
            }
            
            // Restore translation to default when not in use
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
    
    // Allow simultaneous gestures recognized
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // Reset move node position
    func resetMoveNode() {
        parent.moveNodeModel.moveNode.worldPosition = SCNVector3(0, 0, 0)
        parent.moveNodeModel.moveXNode.worldPosition = SCNVector3(0.5, 0, 0)
        parent.moveNodeModel.moveYNode.worldPosition = SCNVector3(0, 0.5, 0)
        parent.moveNodeModel.moveZNode.worldPosition = SCNVector3(0, 0, 0.5)
        parent.moveNodeModel.moveRotationNode.worldPosition = SCNVector3(0, 0, 0)
        
        resetMoveNodeEffect()
    }
    
    // Reset move node effect when not in use
    func resetMoveNodeEffect() {
        parent.moveNodeModel.moveXNode.scale = SCNVector3(1, 1, 1)
        parent.moveNodeModel.moveYNode.scale = SCNVector3(1, 1, 1)
        parent.moveNodeModel.moveZNode.scale = SCNVector3(1, 1, 1)
        
        parent.moveNodeModel.moveXNode.opacity = 0.5
        parent.moveNodeModel.moveYNode.opacity = 0.5
        parent.moveNodeModel.moveZNode.opacity = 0.5
        parent.moveNodeModel.moveRotationNode.opacity = 0.5
    }
    
    // Calculate camera position and rotation with gesture coordinate mapping
    func SCNVector3MultMatrix4(_ vector: SCNVector3, _ matrix: SCNMatrix4) -> SCNVector3 {
        let x = vector.x * matrix.m11 + vector.y * matrix.m21 + vector.z * matrix.m31
        let y = vector.x * matrix.m12 + vector.y * matrix.m22 + vector.z * matrix.m32
        let z = vector.x * matrix.m13 + vector.y * matrix.m23 + vector.z * matrix.m33
        return SCNVector3(x, y, z)
    }
}
