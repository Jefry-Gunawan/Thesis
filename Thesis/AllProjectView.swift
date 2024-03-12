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
    
    @State private var isAlertPresented = false
    @State private var projectName = ""
    @State private var selectedProject: Project = Project(id: UUID(), name: "", data: Data(), roomLength: 0, roomWidth: 0)
    @State private var ARTapped = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, content: {
                    ForEach(projects) { project in
                        ProjectBoxView(project: project)
                            .padding()
                            .contextMenu(ContextMenu(menuItems: {
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
            .padding()
            .navigationTitle("All Projects")
            .toolbar {
                NavigationLink {
                    NewProjectSceneView()
                } label: {
                    Text("New Project")
                }
                
                Button {
                    ARTapped.toggle()
                } label: {
                    Text("AR")
                }

                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Text("Edit")
                })
            }
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("New Project Name", isPresented: $isAlertPresented) {
            TextField("Untitled", text: $projectName)
            Button("OK", action: renameItem)
            Button("Cancel", role: .cancel) { }
        }
        .fullScreenCover(isPresented: $ARTapped, content: {
            ARPageView()
        })
        .onAppear {
            AppDelegate.orientationLock = .landscape
        }
    }
    
    private func deleteProject(selectedProject: Project) {
        withAnimation {
            modelContext.delete(selectedProject)
        }
    }
    
    private func renameItem() {
        selectedProject.name = (projectName != "") ? projectName : "Untitled"
        
        selectedProject = Project(id: UUID(), name: "", data: Data(), roomLength: 0, roomWidth: 0)
        projectName = ""
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to change name")
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
                    .foregroundStyle(.regularMaterial)
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
