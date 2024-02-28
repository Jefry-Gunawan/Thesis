//
//  MoveNodeModel.swift
//  Thesis
//
//  Created by Jefry Gunawan on 17/02/24.
//

import Foundation
import SceneKit

class MoveNodeModel: ObservableObject {
    @Published var cameraNode: SCNNode
    @Published var moveNode: SCNNode
    @Published var moveXNode: SCNNode
    @Published var moveYNode: SCNNode
    @Published var moveZNode: SCNNode
    
    init(cameraNode: SCNNode = SCNNode(), moveNode: SCNNode = SCNNode(), moveXNode: SCNNode = SCNNode(), moveYNode: SCNNode = SCNNode(), moveZNode: SCNNode = SCNNode()) {
        self.cameraNode = cameraNode
        self.moveNode = moveNode
        self.moveXNode = moveXNode
        self.moveYNode = moveYNode
        self.moveZNode = moveZNode
    }
}
