import SwiftUI
import SwiftData

#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
import RealityKit
#endif

struct LoadFloatingButtonView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var isObjectCaptureViewPresented = false
    @State private var isNotSupported = false

    var textColor: Color {
        if colorScheme == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    var project: Project
    
    @Binding var activeScene: ScenekitView
    var actionExport: () -> Void
    var actionShare: () -> Void
    @State var itemCollectionOpened: Bool = false
    
    @ObservedObject var objectDimensionData: ObjectDimensionData
    
    @State private var isRoomSizeAlertPresented = false
    @State private var newWidth: Float = 0
    @State private var newLength: Float = 0
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.regularMaterial)
                        Button(action: {
                            // Hide move node
                            activeScene.moveNodeModel.moveNode.isHidden = true
                            activeScene.objectDimensionData.reset()
                            
                            // Saving existing project
                            self.project.data = activeScene.saveScenetoExistingProject()
                            self.project.snapshotProject = activeScene.saveSnapshot()
                            self.project.roomWidth = activeScene.floorWidth
                            self.project.roomLength = activeScene.floorLength
                            
                            dismiss()
                        }, label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(textColor)
                        })
                    }
                })
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.regularMaterial)
                    
                    Text("\(project.name)")
                        .lineLimit(1)
                        .padding(.horizontal)
                }
                .frame(width: 300, height: 50)
                
                // Dimension Data
                if objectDimensionData.name != nil {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .foregroundStyle(.regularMaterial)
                        HStack {
                            HStack {
                                Text("W :")
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .foregroundStyle(.regularMaterial)
                                    Text("\(objectDimensionData.width ?? "--")")
                                }
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            HStack {
                                Text("L :")
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .foregroundStyle(.regularMaterial)
                                    Text("\(objectDimensionData.length ?? "--")")
                                }
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            HStack {
                                Text("H :")
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .foregroundStyle(.regularMaterial)
                                    Text("\(objectDimensionData.height ?? "--")")
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 50)
                    }
                    // Remove Button
                    Button {
                        activeScene.removeNode()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.regularMaterial)
                            Image(systemName: "trash")
                                .foregroundStyle(.white)
                        }
                    }
                } else {
                    Spacer()
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 300, height: 50)
                        .foregroundStyle(.regularMaterial)
                    HStack {
                        // Open Item Collection
                        Button(action: {
                            itemCollectionOpened.toggle()
                        }, label: {
                            Image(systemName: "chair.lounge.fill")
                                .foregroundStyle(textColor)
                        })
                        .frame(width: 50, height: 50)
                        
                        // Change Room Size
                        Button(action: {
                            self.isRoomSizeAlertPresented = true
                        }, label: {
                            Image(systemName: "house.fill")
                                .foregroundStyle(textColor)
                        })
                        .frame(width: 50, height: 50)
                        
                        Button(action: {
                            #if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
                            if (ObjectCaptureSession.isSupported) {
                                self.isObjectCaptureViewPresented = true
                            } else {
                                self.isNotSupported = true
                            }
                            #else
                            self.isNotSupported = true
                            #endif
                        }, label: {
                            Image(systemName: "viewfinder.rectangular")
                                .foregroundStyle(textColor)
                        })
                        .frame(width: 50, height: 50)
                        
                        Button(action: {
                            actionExport()
                        }, label: {
                            Text("AR")
                                .foregroundStyle(textColor)
                        })
                        .frame(width: 50, height: 50)
                        
                        Button(action: {
                            actionShare()
                        }, label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(textColor)
                        })
                        .frame(width: 50, height: 50)
                    }
                }
                
            }
            .padding()
            .alert("New Project Name", isPresented: $isRoomSizeAlertPresented) {
                TextField("Width", text: Binding(
                    get: { String(newWidth) },
                    set: { newWidth = Float($0) ?? 0 }
                ))
                TextField("Length", text: Binding(
                    get: { String(newLength) },
                    set: { newLength = Float($0) ?? 0 }
                ))
                Button("OK", action: {
                    activeScene.changeFloorSize(width: newWidth, length: newLength)
                })
                Button("Cancel", role: .cancel) { }
            }
            
            if itemCollectionOpened {
                ItemCollectionView(activeScene: $activeScene, itemCollectionOpened: $itemCollectionOpened)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
        .fullScreenCover(isPresented: $isObjectCaptureViewPresented, content: {
            GuidedCaptureView()
        })
#endif
    }
}

//#Preview {
//    FloatingButtonView()
//}
