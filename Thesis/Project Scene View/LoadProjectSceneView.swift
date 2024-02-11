//
//  LoadProjectSceneView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 09/02/24.
//

import SwiftUI
import SwiftData
import SceneKit

struct LoadProjectSceneView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @Query private var testers: [ItemCollection]
    
    var project: Project
    @State var sceneView: ScenekitView
    
    var body: some View {
        ZStack {
            sceneView
                .edgesIgnoringSafeArea(.all)
            
            LoadFloatingButtonView(
                project: self.project,
                activeScene: $sceneView,
                actionExport: {
                    sceneView.export(selector: 1)
                },
                actionShare: {
                    sceneView.export(selector: 2)
                }
            )
        }
        .toolbar(.hidden)
        .onAppear {
            AppDelegate.orientationLock = .landscape
        }
    }
}

//#Preview {
//    LoadProjectSceneView(projectName: <#T##String#>, projectData: <#T##Data#>, sceneView: <#T##ScenekitView#>)
//}

