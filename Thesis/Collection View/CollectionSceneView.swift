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
    
    var collection: ItemCollection
    
    var body: some View {
        ZStack {
            CollectionSceneKitView(collection: collection)
                .edgesIgnoringSafeArea(.all)
            
            FloatingCollectionButtonView()
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
                
                Spacer()
                
            }
            .padding()
            Spacer()
        }
    }
}
