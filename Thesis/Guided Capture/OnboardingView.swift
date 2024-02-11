/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The view that shows the guidance text and tutorials on the review screen.
*/

import Foundation
import RealityKit
import SwiftUI

@available(iOS 17.0, *)
/// View that shows the guidance text and tutorials on the review screen.
struct OnboardingView: View {
    @ObservedObject var appModel: AppDataModel
    @StateObject private var stateMachine: OnboardingStateMachine
    @Environment(\.colorScheme) private var colorScheme

    init(appModel: ObservedObject<AppDataModel>, state: OnboardingState) {
        self._appModel = appModel
        _stateMachine = StateObject(wrappedValue: OnboardingStateMachine(state))
    }

    var body: some View {
        ZStack {
            Color(colorScheme == .light ? .white : .black).ignoresSafeArea()
            if let session = appModel.objectCaptureSession {
                OnboardingTutorialView(appModel: appModel, session: session, onboardingStateMachine: stateMachine)
                OnboardingButtonView(appModel: appModel, session: session, onboardingStateMachine: stateMachine)
            }
        }
        .interactiveDismissDisabled(appModel.objectCaptureSession?.userCompletedScanPass ?? false)
        .allowsHitTesting(!isFinishingOrCompleted)
    }

    private var isFinishingOrCompleted: Bool {
        guard let session = appModel.objectCaptureSession else { return true }
        return session.state == .finishing || session.state == .completed
    }
}
