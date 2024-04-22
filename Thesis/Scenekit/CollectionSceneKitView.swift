import SceneKit
import SwiftUI
import SwiftData

struct CollectionSceneKitView: UIViewRepresentable {
    var scene = SCNScene()
    var view = SCNView()
    var collection: ItemCollection
    
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
            view.scene?.rootNode.addChildNode(loadedNode)
        }
        
        view.pointOfView?.localTranslate(by: SCNVector3(x: 0, y: 0, z: -1))
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
