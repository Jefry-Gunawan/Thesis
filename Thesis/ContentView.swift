//
//  ContentView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 29/03/24.
//

import SwiftUI

struct ContentView: View {
    @State private var menuSelected = 1
    @State private var ARTapped = false
    let buttonGradient = LinearGradient(gradient: Gradient(colors: [.blueButton, .black.opacity(0)]), startPoint: .leading, endPoint: .trailing)
    
    @State var objectDimensionData = ObjectDimensionData()
    @State var arObjectDimensionData = ObjectDimensionData()
    
    @State var rulerMode = false
    @State var rulerDistance: String?
    
    var body: some View {
        GeometryReader{ geometry in
            NavigationStack {
                HStack {
                    ZStack {
                        VStack(alignment: .leading) {
                            // Navigation Title
                            HStack {
                                VStack {
                                    Spacer()
                                    Text("Menu")
                                        .font(.largeTitle)
                                        .bold()
                                        .padding()
                                }
                                Spacer()
                            }
                            .frame(height: 120)
                            .ignoresSafeArea()
                            
                            Button(action: {
                                self.menuSelected = 1
                            }, label: {
                                if menuSelected == 1 {
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(buttonGradient)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        
                                        Text("All Projects")
                                            .foregroundStyle(.white)
                                            .padding(.horizontal)
                                    }
                                } else {
                                    Text("All Projects")
                                        .foregroundStyle(.white)
                                        .padding(.horizontal)
                                }
                            })
                            .frame(height: 50)
                            .padding()
                            
                            Button(action: {
                                self.menuSelected = 2
                            }, label: {
                                if menuSelected == 2 {
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(buttonGradient)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        
                                        Text("3D Collections")
                                            .foregroundStyle(.white)
                                            .padding(.horizontal)
                                    }
                                } else {
                                    Text("3D Collections")
                                        .foregroundStyle(.white)
                                        .padding(.horizontal)
                                }
                            })
                            .frame(height: 50)
                            .padding(.horizontal)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .frame(width: geometry.size.width / 4, height: geometry.size.height)
                    .background(.regularMaterial)
                    
                    // Projects & Collections
                    ZStack {
                        VStack(alignment: .leading) {
                            // Navigation Title
                            HStack {
                                VStack {
                                    Spacer()
                                    if menuSelected == 1 {
                                        Text("Projects")
                                            .font(.largeTitle)
                                            .bold()
                                            .padding()
                                    } else {
                                        Text("3D Collections")
                                            .font(.largeTitle)
                                            .bold()
                                            .padding()
                                    }
                                    
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Spacer()
                                    HStack {
                                        Button {
                                            ARTapped.toggle()
                                        } label: {
                                            Text("AR")
                                                .foregroundStyle(.blueButton)
                                        }
                                    }
                                    .padding()
                                }
                            }
                            .frame(height: 120)
                            .ignoresSafeArea()
                            
                            if self.menuSelected == 1 {
                                AllProjectView(objectDimensionData: objectDimensionData)
                            } else if self.menuSelected == 2 {
                                AllCollectionView()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(width: geometry.size.width * 3 / 4, height: geometry.size.height)
                    
                }
                
                .toolbar(.hidden)
                .background(
                    Image("Background App")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                )
            }
            .ignoresSafeArea()
            .fullScreenCover(isPresented: $ARTapped, content: {
                ARPageView(arView: ARViewContainer(objectDimensionData: arObjectDimensionData, rulerMode: $rulerMode, rulerDistance: $rulerDistance), objectDimensionData: arObjectDimensionData, rulerMode: $rulerMode, rulerDistance: $rulerDistance)
            })
            .onAppear {
                AppDelegate.orientationLock = .landscape
            }
        }
    }
}

#Preview {
    ContentView()
}
