//
//  ColorPickerView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 29/06/24.
//

import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.regularMaterial)
                
                ColorPicker("Set the background color", selection: $selectedColor, supportsOpacity: false)
                    .padding()
            }
            .frame(width: 300, height: 50)
        }
    }
}
