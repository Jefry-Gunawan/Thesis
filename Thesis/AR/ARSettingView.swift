//
//  ARSettingView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 29/06/24.
//

import SwiftUI

struct ARSettingView: View {
    @Binding var activeARView: ARViewContainer
    @Binding var physicsOn: Bool
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.regularMaterial)
                
                Toggle("Physic Simulation", isOn: $physicsOn)
                    .toggleStyle(SwitchToggleStyle(tint: .blueButton))
                    .padding()
                    .onChange(of: physicsOn) { oldValue, newValue in
                        activeARView.changePhysics()
                    }
                
            }
            .frame(width: 300, height: 50)
        }
    }
}
