#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
import RealityKit
import SwiftUI
import os


@available(iOS 17.0, *)
struct GuidedCaptureView: View {
    static let logger = Logger(subsystem: ThesisApp.subsystem,
                                category: "GuidedCaptureView")

    @StateObject var appModel: AppDataModel = AppDataModel()
    
    @State private var showReconstructionView: Bool = false
    @State private var showErrorAlert: Bool = false
    private var showProgressView: Bool {
        appModel.state == .completed || appModel.state == .restart || appModel.state == .ready
    }

    var body: some View {
        VStack {
            if appModel.state == .capturing {
                if let session = appModel.objectCaptureSession {
                    CapturePrimaryView(appModel: appModel, session: session)
                }
            } else if showProgressView {
                CircularProgressView()
            }
        }
        .onAppear {
            //AppDelegate.orientationLock = .portrait // And making sure it stays that way
        }
        .onChange(of: appModel.state) { _, newState in
            if newState == .failed {
                showErrorAlert = true
                showReconstructionView = false
            } else {
                showErrorAlert = false
                showReconstructionView = newState == .reconstructing || newState == .viewing
            }
        }
        .fullScreenCover(isPresented: $showReconstructionView) {
            if let folderManager = appModel.scanFolderManager {
                ReconstructionPrimaryView(appModel: appModel, outputFile: folderManager.modelsFolder.appendingPathComponent("model-mobile.usdz"))
            }
        }
        .alert(
            "Failed:  " + (appModel.error != nil  ? "\(String(describing: appModel.error!))" : ""),
            isPresented: $showErrorAlert,
            actions: {
                Button("OK") {
                    GuidedCaptureView.logger.log("Calling restart...")
                    appModel.state = .restart
                }
            },
            message: {}
        )
    }
}

private struct CircularProgressView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: colorScheme == .light ? .black : .white))
                Spacer()
            }
            Spacer()
        }
    }
}
#endif
