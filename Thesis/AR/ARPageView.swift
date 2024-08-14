//
//  ARPageView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 28/02/24.
//
#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
import SwiftUI

struct ARPageView: View {
    @State var arView: ARViewContainer
    @ObservedObject var objectDimensionData: ObjectDimensionData
    @Binding var rulerMode: Bool
    @Binding var rulerDistance: String?
    @Binding var physicsOn: Bool
    
    @Binding var colorToggle: Bool
    @Binding var selectedColor: Color
    
    var body: some View {
        ZStack {
            arView
                .edgesIgnoringSafeArea(.all)
            
            ARFloatingMenu(activeARView: $arView, objectDimensionData: objectDimensionData, rulerMode: $rulerMode, rulerDistance: $rulerDistance, physicsOn: $physicsOn, colorToggle: $colorToggle, selectedColor: $selectedColor)
        }
        .toolbar(.hidden)
    }
}
#endif

//#Preview {
//    ARPageView()
//}
