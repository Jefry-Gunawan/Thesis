/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
State enumeration for the data model type that maintains the state of the app.
*/

#if !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
import Foundation

extension AppDataModel {
    enum ModelState: String, CustomStringConvertible {
        var description: String { rawValue }

        case notSet
        case ready
        case capturing
        case prepareToReconstruct
        case reconstructing
        case viewing
        case completed
        case restart
        case failed
        case ended
    }
}
#endif
