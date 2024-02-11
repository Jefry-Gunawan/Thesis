//
//  AllProjectView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 07/02/24.
//

import SwiftUI
import SwiftData

struct AllProjectView: View {
    // Database
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, content: {
                    ForEach(projects) { project in
                        ProjectBoxView(project: project)
                            .contextMenu(ContextMenu(menuItems: {
                                Button(action: {
                                    deleteProject(selectedProject: project)
                                }, label: {
                                    Text("Delete")
                                })
                            }))
                    }
                })
                
            }
            .padding()
            .navigationTitle("All Projects")
            .toolbar {
                NavigationLink {
                    NewProjectSceneView()
                } label: {
                    Image(systemName: "plus")
                }

                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Text("Edit")
                })
            }
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            AppDelegate.orientationLock = .landscape
        }
    }
    
    private func deleteProject(selectedProject: Project) {
        withAnimation {
            modelContext.delete(selectedProject)
        }
    }
}

struct ProjectBoxView: View {
    @Environment(\.colorScheme) var colorScheme

    var textColor: Color {
        if colorScheme == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    var project: Project
    
    var body: some View {
        NavigationLink {
            LoadProjectSceneView(project: project, sceneView: ScenekitView(loadSceneBool: true, loadedProject: project.data))
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                Text("\(project.name)")
                    .foregroundStyle(textColor)
            }
            .frame(width: 250, height: 200)
        }
    }
}

#Preview {
    AllProjectView()
}
