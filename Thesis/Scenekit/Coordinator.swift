import Foundation
import SwiftUI
import SceneKit
import QuickLook

class Coordinator: NSObject, UIGestureRecognizerDelegate {
    var parent: ScenekitView
    private var selectedNode: SCNNode?
    
    private var lastPanTranslation: CGPoint = .zero
    
    init(_ parent: ScenekitView) {
        self.parent = parent
        super.init()
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let p = gestureRecognizer.location(in: parent.view)
        let hitResults = parent.view.hitTest(p, options: [:])
        
        if hitResults.count > 0 {
            if let result = hitResults.first {
                print("Result Name : \(result.node.name ?? "")")
                parent.isEditMode = true
                
                selectedNode = result.node
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(Coordinator.handlePan(_:)))
                panGesture.delegate = self
                parent.view.addGestureRecognizer(panGesture)
            }
        } else {
            parent.isEditMode = false
        }
        
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let selectedNode = selectedNode else { return }
            
        let translation = gestureRecognizer.translation(in: parent.view)
        let delta = SIMD2(Float(translation.x - lastPanTranslation.x), Float(translation.y - lastPanTranslation.y))
        
        var currentPosition = selectedNode.position
        currentPosition.x += delta.x * 0.01 // Adjust the sensitivity as needed
        currentPosition.y -= delta.y * 0.01 // Adjust the sensitivity as needed
        
        selectedNode.position = currentPosition
        lastPanTranslation = translation
        
        if gestureRecognizer.state == .ended {
            lastPanTranslation = .zero
        }
    }
}
