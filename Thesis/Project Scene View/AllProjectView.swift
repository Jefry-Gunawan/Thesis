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
        GridItem(.flexible())
    ]
    
    @State private var isAlertPresented = false
    @State private var projectName = ""
    @State private var selectedProject: Project = Project(id: UUID(), name: "", data: Data(), roomLength: 0, roomWidth: 0, snapshotProject: Data())
    
    @State private var ARTapped = false
    
    @ObservedObject var objectDimensionData: ObjectDimensionData
    
    // For Light Mode & Dark Mode support
    @Environment(\.colorScheme) var colorScheme
    var textColor: Color {
        if colorScheme == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, content: {
                // Button for New Project
                NavigationLink {
                    NewProjectSceneView(sceneView: ScenekitView(loadSceneBool: false, objectDimensionData: objectDimensionData), objectDimensionData: objectDimensionData)
                } label: {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.regularMaterial)
                            Image(systemName: "plus")
                                .resizable()
                                .foregroundStyle(.regularMaterial)
                                .frame(width: 120, height: 120)
                        }
                        .frame(width: 250, height: 200)
                        Text("New Project")
                            .foregroundStyle(textColor)
                    }
                }
                
                ForEach(projects) { project in
                    ProjectBoxView(project: project, objectDimensionData: objectDimensionData)
                        .padding()
                        .contextMenu(ContextMenu(menuItems: {
                            Button(action: {
                                duplicateProject(selectedProject: project)
                            }, label: {
                                Text("Duplicate")
                            })
                            Button(action: {
                                isAlertPresented.toggle()
                                selectedProject = project
                            }, label: {
                                Text("Rename")
                            })
                            Button(role: .destructive) {
                                deleteProject(selectedProject: project)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }))
                }
            })
            
        }
        .alert("New Project Name", isPresented: $isAlertPresented) {
            TextField("Untitled", text: $projectName)
            Button("OK", action: renameItem)
            Button("Cancel", role: .cancel) { }
        }
//        .fullScreenCover(isPresented: $ARTapped, content: {
//            ARPageView()
//        })
//        .onAppear {
//            AppDelegate.orientationLock = .landscape
//        }
    }
    
    private func deleteProject(selectedProject: Project) {
        withAnimation {
            modelContext.delete(selectedProject)
        }
    }
    
    private func renameItem() {
        selectedProject.name = (projectName != "") ? projectName : "Untitled"
        
        selectedProject = Project(id: UUID(), name: "", data: Data(), roomLength: 0, roomWidth: 0, snapshotProject: Data())
        projectName = ""
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to change name")
        }
    }
    
    private func duplicateProject(selectedProject: Project) {
        let newProject = Project(id: UUID(),
                                 name: "\(selectedProject.name) copy",
                                 data: selectedProject.data,
                                 roomLength: selectedProject.roomLength,
                                 roomWidth: selectedProject.roomWidth,
                                 snapshotProject: selectedProject.snapshotProject)
        modelContext.insert(newProject)
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
    @ObservedObject var objectDimensionData: ObjectDimensionData
    
    var body: some View {
        NavigationLink {
            LoadProjectSceneView(project: project, sceneView: ScenekitView(loadSceneBool: true, loadedProject: project.data, floorWidth: project.roomWidth, floorLength: project.roomLength, objectDimensionData: objectDimensionData), objectDimensionData: objectDimensionData)
        } label: {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.regularMaterial)
                    Image(uiImage: UIImage(data: project.snapshotProject)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 246, height: 196)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .frame(width: 250, height: 200)
                Text("\(project.name)")
                    .foregroundStyle(textColor)
            }
        }
    }
}
