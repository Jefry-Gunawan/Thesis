//
//  FloatingButtonView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 02/02/24.
//

import SwiftUI
import SwiftData

#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
import RealityKit
#endif

struct FloatingButtonView: View {
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
    
    @Binding var activeScene: ScenekitView
    var actionExport: () -> Void
    var actionShare: () -> Void
    @State var itemCollectionOpened: Bool = false
    
    @ObservedObject var objectDimensionData: ObjectDimensionData
    
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
                            // Saving project
                            let newProject = activeScene.saveNewScene()
                            modelContext.insert(newProject)
                            
                            dismiss()
                        }, label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(textColor)
                        })
                    }
                })
                
                Spacer()
                
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
                        Button(action: {
                            itemCollectionOpened.toggle()
                        }, label: {
                            Image(systemName: "chair.lounge.fill")
                                .foregroundStyle(textColor)
                        })
                        .frame(width: 50, height: 50)
                        
                        Button(action: {}, label: {
                            Image(systemName: "house.fill")
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
            
            if itemCollectionOpened {
                ItemCollectionView(activeScene: $activeScene, itemCollectionOpened: $itemCollectionOpened)
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

//#Preview {
//    FloatingButtonView()
//}
