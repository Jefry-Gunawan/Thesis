//
//  ARFloatingMenu.swift
//  Thesis
//
//  Created by Jefry Gunawan on 29/02/24.
//

import SwiftUI
import SwiftData

#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
import RealityKit
#endif

struct ARFloatingMenu: View {
    @Environment(\.modelContext) private var modelContext
//    @Query private var projects: [Project]
    
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
    
    @Binding var activeARView: ARViewContainer
//    var actionExport: () -> Void
//    var actionShare: () -> Void
    @State var itemCollectionOpened: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                // Back Button
                Button(action: {
                    
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.regularMaterial)
                        Button(action: {
                            // Saving project
//                            let newProject = activeScene.saveNewScene()
//                            modelContext.insert(newProject)
                            
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
                        .frame(width: 180, height: 50)
                        .foregroundStyle(.regularMaterial)
                    HStack {
                        Button(action: {
                            itemCollectionOpened.toggle()
                        }, label: {
                            Image(systemName: "chair.lounge.fill")
                                .foregroundStyle(textColor)
                        })
                        .frame(width: 50, height: 50)
                        
                        // Object Capture
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
//                            actionShare()
                        }, label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(textColor)
                        })
                        .frame(width: 50, height: 50)
                    }
                }
                
            }
            .padding()
            
            if itemCollectionOpened {
                ARItemCollectionView(activeARView: $activeARView)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
#if !targetEnvironment(simulator)
        .fullScreenCover(isPresented: $isObjectCaptureViewPresented, content: {
            GuidedCaptureView()
        })
#endif
    }
}
