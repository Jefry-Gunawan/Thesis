//
//  ARPageView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 28/02/24.
//
#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
import SwiftUI

struct ARPageView: View {
    @State var arView: ARViewContainer = ARViewContainer()
    
    var body: some View {
        ZStack {
            arView
                .edgesIgnoringSafeArea(.all)
            
            ARFloatingMenu(activeARView: $arView)
        }
        .toolbar(.hidden)
    }
}
#endif

//#Preview {
//    ARPageView()
//}
