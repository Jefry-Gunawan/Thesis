import SceneKit
import SwiftUI
import SwiftData

struct CollectionSceneKitView: UIViewRepresentable {
    var scene = SCNScene()
    var view = SCNView()
    var collection: ItemCollection
    
    var usdzURL: URL?
    
    @ObservedObject var objectDimensionData: ObjectDimensionData
    
    @Binding var selectedColor: Color
    
    func makeUIView(context: Context) -> some UIView {
        view.scene = scene
        view.allowsCameraControl = true
        view.backgroundColor = UIColor(selectedColor)
        
        // To ensure ambient light will be added only once
        if ((view.scene?.rootNode.childNode(withName: "AmbientLightNode", recursively: true)) == nil) {
            let ambientLight = SCNLight()
            ambientLight.type = .ambient
            ambientLight.intensity = 1000.0
            let ambientLightNode = SCNNode()
            ambientLightNode.light = ambientLight
            ambientLightNode.name = "AmbientLightNode"
            view.scene?.rootNode.addChildNode(ambientLightNode)
        }
        
        let fileManager = FileManager.default
        do {
            // Get the documents directory URL
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            // Construct the file URL using the relative path
            let fileURL = documentsURL.appendingPathComponent(collection.dataURL)
            
            if fileManager.fileExists(atPath: fileURL.path) {
                print("File exists at URL: \(fileURL)")
                
                if let modelasset = try? SCNScene(url: fileURL), let loadedNode = modelasset.rootNode.childNodes.first?.clone() {
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
                    objectDimensionData.width = String(format: "%.3f", width)
                    objectDimensionData.height = String(format: "%.3f", height)
                    objectDimensionData.length = String(format: "%.3f", length)
                    
                    view.scene?.rootNode.addChildNode(loadedNode)
                }
            } else {
                print("File does not exist at URL: \(fileURL)")
            }
        } catch {
            print("Error accessing file: \(error)")
        }
        
//        view.pointOfView?.localTranslate(by: SCNVector3(x: 0, y: 0, z: 1))
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        view.backgroundColor = UIColor(selectedColor)
    }
    
    func export(selector: Int) {
        let exportUSDZ = ExportUSDZ(scene: self.view.scene!, view: self.view, usdzURL: self.usdzURL)
        exportUSDZ.exportNodeToUSDZ(selector: selector, name: "\(collection.name).usdz")
    }
}
