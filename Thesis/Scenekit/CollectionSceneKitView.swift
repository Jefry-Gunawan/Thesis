import SceneKit
import SwiftUI
import SwiftData

struct CollectionSceneKitView: UIViewRepresentable {
    var scene = SCNScene()
    var view = SCNView()
    var collection: ItemCollection
    
    var usdzURL: URL?
    
    @ObservedObject var objectDimensionData: ObjectDimensionData
    
    func makeUIView(context: Context) -> some UIView {
        view.scene = scene
        view.allowsCameraControl = true
        view.backgroundColor = .black
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 500.0
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        view.scene?.rootNode.addChildNode(ambientLightNode)
        
        if let loadedNode = try! NSKeyedUnarchiver.unarchivedObject(ofClass: SCNNode.self, from: collection.data) {
            // Get dimension
            loadedNode.eulerAngles.y = 0
            
            let worldBoundingBox = loadedNode.boundingBox
            let worldMin = loadedNode.convertPosition(worldBoundingBox.min, to: nil)
            let worldMax = loadedNode.convertPosition(worldBoundingBox.max, to: nil)
            
            // Get width length height
            let width = worldMax.x - worldMin.x
            let height = worldMax.y - worldMin.y
            let length = worldMax.z - worldMin.z
            
            objectDimensionData.name = loadedNode.name ?? "Untitled"
            objectDimensionData.width = String(format: "%.2f", width)
            objectDimensionData.height = String(format: "%.2f", height)
            objectDimensionData.length = String(format: "%.2f", length)
            
            view.scene?.rootNode.addChildNode(loadedNode)
        }
        
        view.pointOfView?.localTranslate(by: SCNVector3(x: 0, y: 0, z: -1))
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func export(selector: Int) {
        let exportUSDZ = ExportUSDZ(scene: self.view.scene!, view: self.view, usdzURL: self.usdzURL)
        exportUSDZ.exportNodeToUSDZ(selector: selector, name: "\(collection.name).usdz")
    }
}
