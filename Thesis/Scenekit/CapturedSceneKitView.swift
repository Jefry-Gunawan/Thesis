import SceneKit
import SwiftUI
import SwiftData

struct CapturedSceneKitView: UIViewRepresentable {
    var scene = SCNScene()
    var view = SCNView()
    var usdzURL: URL
    
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
        
        loadScene()
        
//        view.pointOfView?.localTranslate(by: SCNVector3(x: 0, y: 0, z: 1))
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func loadScene() {
        print("URL : \(usdzURL)")
        
        if let modelasset = try? SCNScene(url: usdzURL), let modelNode = modelasset.rootNode.childNodes.first?.clone() {
            self.view.scene?.rootNode.addChildNode(modelNode)
        }
    }
}
