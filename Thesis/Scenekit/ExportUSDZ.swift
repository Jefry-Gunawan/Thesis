//
//  ExportUSDZ.swift
//  Thesis
//
//  Created by Jefry Gunawan on 05/02/24.
//

import Foundation
import SwiftUI
import SceneKit
import QuickLook
import ARKit

class ExportUSDZ {
    var scene: SCNScene
    var view: SCNView
    var usdzURL: URL?
    
    init(scene: SCNScene, view: SCNView, usdzURL: URL? = nil) {
        let newScene = SCNScene()
        for childnode in scene.rootNode.childNodes {
            if childnode.name != "defaultFloor" {
                let clonedNode = childnode.clone()
                newScene.rootNode.addChildNode(clonedNode)
            }
        }
        self.scene = newScene
        self.view = view
        self.usdzURL = usdzURL
    }
    
    // 1 = AR, 2 = ShareSheet
    func exportNodeToUSDZ(selector: Int) {
        // Create a temporary directory URL to store the USDZ file
        guard let tempDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Unable to access temporary directory.")
            return
        }
        
        let usdzFileName = "model.usdz"
        let usdzFileURL = tempDirectoryURL.appendingPathComponent(usdzFileName)
        
        // Export the node to USDZ file
        do {
            try scene.write(to: usdzFileURL, options: nil, delegate: nil, progressHandler: nil)
            usdzURL = usdzFileURL
            
            if selector == 1 {
                openARViewer()
            } else if selector == 2 {
                shareSheet()
            }
            
        } catch {
            print("Error: Unable to export node to USDZ - \(error)")
        }
    }
    
    //    func openARViewer() {
    //        guard let usdzURL = usdzURL else {
    //            print("Error: USDZ URL is missing.")
    //            return
    //        }
    //
    //        let arView = ARSCNView(frame: UIScreen.main.bounds)
    //        arView.autoenablesDefaultLighting = true
    //        let scene = try? SCNScene(url: usdzURL)
    //        arView.scene = scene!
    //
    //        let viewController = UIViewController()
    //        viewController.view = arView
    //
    ////       Present the AR Viewer
    //        UIApplication.shared.windows.first?.rootViewController?.present(viewController, animated: true, completion: nil)
    //    }
    
    func openARViewer() {
        let quickLookController = QLPreviewController()
        quickLookController.dataSource = self
        
        // Present the AR Viewer
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        guard let firstWindow = firstScene.windows.first else {
            return
        }
        firstWindow.rootViewController?.present(quickLookController, animated: true, completion: nil)
    }
    
    func shareSheet() {
        guard let usdzURL = usdzURL else {
            print("Error: USDZ URL is missing.")
            return
        }
        
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        guard let firstWindow = firstScene.windows.first else {
            return
        }
        guard let rootViewController = firstWindow.rootViewController else {
            print("Error: Unable to access root view controller.")
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [usdzURL], applicationActivities: nil)
        
        // Customize the activity view controller if needed
//        activityViewController.popoverPresentationController?.sourceView = rootViewController.view // For iPads
        
        // Wrap the activity view controller in a navigation controller to present it modally
        let navigationController = UINavigationController(rootViewController: activityViewController)
        
        // Present the share sheet modally
        rootViewController.present(navigationController, animated: true, completion: nil)
    }
}

extension ExportUSDZ: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let url = usdzURL else {
            fatalError("USDZ URL is missing.")
        }
        return url as QLPreviewItem
    }
}