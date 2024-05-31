//
//  CollectionSceneView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 20/04/24.
//

import SwiftUI
import SwiftData
import SceneKit

struct CollectionSceneView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State var scene: CollectionSceneKitView
    
    @ObservedObject var objectDimensionData: ObjectDimensionData
    
    var name: String
    
    var body: some View {
        ZStack {
            scene
                .edgesIgnoringSafeArea(.all)
            
            FloatingCollectionButtonView(scene: $scene, objectDimensionData: self.objectDimensionData, name: name)
        }
        .toolbar(.hidden)
        .onAppear {
            AppDelegate.orientationLock = .landscape
        }
    }
}

struct FloatingCollectionButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @Binding var scene: CollectionSceneKitView
    @ObservedObject var objectDimensionData: ObjectDimensionData
    
    var name: String
    
    var textColor: Color {
        if colorScheme == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
    
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
                            dismiss()
                        }, label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(textColor)
                        })
                    }
                })
                
                // Collection name
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.regularMaterial)
                    
                    Text("\(self.name)")
                        .lineLimit(1)
                        .padding(.horizontal)
                }
                .frame(width: 300, height: 50)
                
                // Dimension
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
                
                // Share export button
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.regularMaterial)
                    Button(action: {
                        scene.export(selector: 2)
                    }, label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(textColor)
                    })
                    .frame(width: 50, height: 50)
                }

            }
            .padding()
            Spacer()
        }
    }
}
