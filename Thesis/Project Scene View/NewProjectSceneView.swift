//
//  ContentView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 30/01/24.
//

import SwiftUI
import SwiftData
import SceneKit

struct NewProjectSceneView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @Query private var testers: [ItemCollection]
    
    @State var sceneView: ScenekitView = ScenekitView(loadSceneBool: false)
    
    @State private var itemCollectionOpened: Bool = false
    
    var body: some View {
        ZStack {
            sceneView
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                FloatingButtonView(
                    activeScene: $sceneView,
                    actionExport: {
                        sceneView.export(selector: 1)
                    },
                    actionShare: {
                        sceneView.export(selector: 2)
                    },
                    itemCollectionOpened: $itemCollectionOpened
                )
                
                if itemCollectionOpened {
                    ItemCollectionView()
                }
            }
        }
        .toolbar(.hidden)
        .onAppear {
            AppDelegate.orientationLock = .landscape
        }
    }
}

#Preview {
    NewProjectSceneView()
}
