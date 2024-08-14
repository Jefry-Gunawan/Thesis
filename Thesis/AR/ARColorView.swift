//
//  ARColorView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 03/07/24.
//

import SwiftUI

struct ARColorView: View {
    @Binding var activeARView: ARViewContainer
    
    @Binding var colorToggle: Bool
    @Binding var selectedColor: Color
    
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.regularMaterial)
                
                VStack {
                    Toggle("Color change", isOn: $colorToggle)
                        .toggleStyle(SwitchToggleStyle(tint: .blueButton))
                        .padding()
                        .onChange(of: colorToggle) { oldValue, newValue in
                            activeARView.changeMaterial(colorToggle: self.colorToggle)
                        }
                    
                    if colorToggle {
                        ColorPicker("Set the object color", selection: $selectedColor, supportsOpacity: false)
                            .padding()
                    }
                }
            }
            .frame(width: 300, height: 100)
        }
    }
}
