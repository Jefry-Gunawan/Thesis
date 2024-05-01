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
    
    var body: some View {
        ZStack {
            arView
                .edgesIgnoringSafeArea(.all)
            
            ARFloatingMenu(activeARView: $arView, objectDimensionData: objectDimensionData)
        }
        .toolbar(.hidden)
    }
}
#endif

//#Preview {
//    ARPageView()
//}
