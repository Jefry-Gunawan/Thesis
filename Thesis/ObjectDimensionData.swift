//
//  ObjectDimensionData.swift
//  Thesis
//
//  Created by Jefry Gunawan on 22/04/24.
//

import Foundation
import RealityKit
import SceneKit

class ObjectDimensionData: ObservableObject {
    @Published var name: String?
    @Published var width: String?
    @Published var length: String?
    @Published var height: String?
    
    @Published var selectedEntity: Entity?
    @Published var selectedNode: SCNNode?
    
    init() {
        self.name = nil
        self.width = nil
        self.length = nil
        self.height = nil
        self.selectedEntity = nil
        self.selectedNode = nil
    }
    
    func reset() {
        self.name = nil
        self.width = nil
        self.length = nil
        self.height = nil
        self.selectedEntity = nil
        self.selectedNode = nil
    }
}
