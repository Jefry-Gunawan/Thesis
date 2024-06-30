//
//  ARFloatingMenu.swift
//  Thesis
//
//  Created by Jefry Gunawan on 29/02/24.
//

import SwiftUI
import SwiftData
import AVKit

#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
import RealityKit
#endif

struct ARFloatingMenu: View {
    @Environment(\.modelContext) private var modelContext
//    @Query private var projects: [Project]
    
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
    
#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
    @Binding var activeARView: ARViewContainer
#endif
    @State var itemCollectionOpened: Bool = false
    
    @ObservedObject var objectDimensionData: ObjectDimensionData
    
    @Binding var rulerMode: Bool
    @Binding var rulerDistance: String?
    
    @State private var timer: Timer?
    
    @State private var settingViewBool = false
    @Binding var physicsOn: Bool
    
    var body: some View {
        ZStack {
            // Button snapshot biar center dan bagus
            VStack {
                Spacer()
                
                HStack {
                    // Only show button when there is entity inside
                    if objectDimensionData.selectedEntity != nil {
                        VStack {
                            Button {
                                self.stopTimer()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(.regularMaterial)
                                    Image(systemName: "chevron.up")
                                        .foregroundStyle(textColor)
                                }
                            }
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.1)
                                    .onEnded { _ in
                                        self.startTimer(selectorUp: true)
                                    }
                            )
                            .padding(.bottom)
                            
                            Button {
                                self.stopTimer()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(.regularMaterial)
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(textColor)
                                }
                            }
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.1)
                                    .onEnded { _ in
                                        self.startTimer(selectorUp: false)
                                    }
                            )
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 6)
                            .foregroundColor(.white)
                            .frame(width: 65, height: 65)
                        
                        Button {
                            activeARView.takesnapshot()
                            AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1108), nil)
                        } label: {
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            
            // Floating Button
            VStack {
                HStack {
                    // Back Button
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
                    
                    if self.rulerMode {
                        // Dimension Data
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .foregroundStyle(.regularMaterial)
                            HStack {
                                Spacer()
                                
                                HStack {
                                    Text("Distance :")
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .foregroundStyle(.regularMaterial)
                                        Text("\(rulerDistance ?? "--") M")
                                    }
                                }
                                .padding(.horizontal)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: 50)
                        }
                    } else {
                        if objectDimensionData.name != nil {
                            // Dimension Data
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
                                            Text("\(objectDimensionData.width ?? "--") M")
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
                                            Text("\(objectDimensionData.length ?? "--") M")
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
                                            Text("\(objectDimensionData.height ?? "--") M")
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 50)
                            }
                            
                            // Remove Button
                            Button {
                                activeARView.removeEntity()
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
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 240, height: 50)
                            .foregroundStyle(.regularMaterial)
                        HStack {
                            // Setting button
                            Button(action: {
                                self.settingViewBool.toggle()
                                itemCollectionOpened = false
                            }, label: {
                                if self.settingViewBool {
                                    Image(systemName: "paintbrush.fill")
                                        .foregroundStyle(.blueButton)
                                } else {
                                    Image(systemName: "paintbrush.fill")
                                        .foregroundStyle(textColor)
                                }
                            })
                            .frame(width: 50, height: 50)
                            
                            // Item Collection Button
                            Button(action: {
                                itemCollectionOpened.toggle()
                                settingViewBool = false
                            }, label: {
                                if itemCollectionOpened {
                                    Image(systemName: "chair.lounge.fill")
                                        .foregroundStyle(.blueButton)
                                } else {
                                    Image(systemName: "chair.lounge.fill")
                                        .foregroundStyle(textColor)
                                }
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
                                self.rulerMode.toggle()
                            }, label: {
                                if self.rulerMode {
                                    Image(systemName: "ruler")
                                        .foregroundStyle(.blue)
                                } else {
                                    Image(systemName: "ruler")
                                        .foregroundStyle(textColor)
                                }
                            })
                            .frame(width: 50, height: 50)
                        }
                    }
                    
                }
                .padding()
    #if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
                if itemCollectionOpened {
                    ARItemCollectionView(activeARView: $activeARView, itemCollectionOpened: $itemCollectionOpened)
                        .padding(.horizontal)
                }
    #endif
                
                if self.settingViewBool {
                    ARSettingView(activeARView: $activeARView, physicsOn: $physicsOn)
                        .padding(.horizontal)
                }
                Spacer()
            }
        }
#if !targetEnvironment(simulator)
        .fullScreenCover(isPresented: $isObjectCaptureViewPresented, content: {
            GuidedCaptureView()
        })
#endif
    }
    
    // Ensure smooth up movement
    private func startTimer(selectorUp: Bool) {
            // Invalidate any existing timer
            self.timer?.invalidate()
            // Create and schedule a new timer
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
                DispatchQueue.main.async {
                    activeARView.moveObjectVertical(selectorUp: selectorUp)
                }
            }
        }

        private func stopTimer() {
            // Invalidate the timer
            self.timer?.invalidate()
            self.timer = nil
        }
}
