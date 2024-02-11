import SwiftUI
import SwiftData
import RealityKit

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
                            // Saving existing project
                            self.project.data = activeScene.saveScenetoExistingProject()
                            
                            dismiss()
                        }, label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(textColor)
                        })
                    }
                })
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 300, height: 50)
                        .foregroundStyle(.regularMaterial)
                    HStack {
                        Button(action: {}, label: {
                            Image(systemName: "chair.lounge.fill")
                                .foregroundStyle(textColor)
                        })
                        .frame(width: 50, height: 50)
                        
                        Button(action: {}, label: {
                            Image(systemName: "house.fill")
                                .foregroundStyle(textColor)
                        })
                        .frame(width: 50, height: 50)
                        
                        Button(action: {
                            if (ObjectCaptureSession.isSupported) {
                                self.isObjectCaptureViewPresented = true
                            } else {
                                self.isNotSupported = true
                            }
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
            Spacer()
        }
        .fullScreenCover(isPresented: $isObjectCaptureViewPresented, content: {
            GuidedCaptureView()
        })
    }
}

//#Preview {
//    FloatingButtonView()
//}
